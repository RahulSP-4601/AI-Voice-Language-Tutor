import { NextResponse } from "next/server";
import { enforceRateLimit, getRequestIp } from "@/lib/api-rate-limit";
import { type CourseSlug, isCourseSlug } from "@/lib/course-definitions";
import { fetchWithTimeout, isAbortError } from "@/lib/runtime-guards";
import { getTutorSpeechModels } from "@/lib/tutor-speech";

export const runtime = "nodejs";
export const maxDuration = 30;

type SpeechRequestBody = {
  slug?: string;
  text?: string;
};

type SynthesizedSpeech = {
  audio: Uint8Array;
  contentType: string;
  usedFallback: boolean;
  voiceModel: string;
};

type CachedSpeechEntry = {
  bytes: number;
  contentType: string;
  expiresAt: number;
  payload: Uint8Array;
  usedFallback: boolean;
  voiceModel: string;
};

const SPEECH_CACHE_TTL_MS = 60 * 60 * 1000;
const SPEECH_CACHE_MAX_ENTRIES = 400;
const SPEECH_CACHE_MAX_BYTES = 64 * 1024 * 1024;
const SPEECH_REQUEST_BUDGET_MS = 24_000;
const SPEECH_ATTEMPT_TIMEOUT_MS = 10_000;
const SPEECH_TIMEOUT_FLOOR_MS = 1_500;
const speechCache = new Map<string, CachedSpeechEntry>();
const inflightSpeech = new Map<string, Promise<SynthesizedSpeech>>();
let speechCacheBytes = 0;

function getDeepgramKey() {
  const value = process.env.DEEPGRAM_API_KEY;
  if (!value || !value.trim()) {
    throw new Error("Missing required environment variable: DEEPGRAM_API_KEY");
  }

  return value.trim();
}

function parseBody(body: SpeechRequestBody) {
  const slug = body.slug?.trim();
  const text = body.text?.trim();

  if (!slug || !isCourseSlug(slug) || !text || text.length > 400) {
    return null;
  }

  return { slug, text };
}

function getVoiceCandidates(slug: CourseSlug) {
  const models = getTutorSpeechModels(slug);
  return [models.primaryModel, models.backupModel].filter(
    (value, index, values): value is string => Boolean(value) && values.indexOf(value) === index,
  );
}

async function generateSpeechAttempt(input: {
  remainingMs: number;
  text: string;
  usedFallback: boolean;
  voiceModel: string;
}) {
  const response = await fetchWithTimeout(
    `https://api.deepgram.com/v1/speak?model=${encodeURIComponent(
      input.voiceModel,
    )}&encoding=mp3`,
    {
      body: JSON.stringify({ text: input.text }),
      headers: {
        Authorization: `Token ${getDeepgramKey()}`,
        "Content-Type": "application/json",
      },
      method: "POST",
      timeoutMs: Math.min(SPEECH_ATTEMPT_TIMEOUT_MS, input.remainingMs),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(errorText || "Deepgram speech generation failed.");
  }

  const audioBuffer = await response.arrayBuffer();
  return {
    audio: new Uint8Array(audioBuffer),
    contentType: response.headers.get("Content-Type") ?? "audio/mpeg",
    usedFallback: input.usedFallback,
    voiceModel: input.voiceModel,
  } satisfies SynthesizedSpeech;
}

function getRequestErrorMessage(error: unknown) {
  if (isAbortError(error)) {
    return "Tutor speech generation timed out.";
  }

  if (error instanceof Error && error.message.trim()) {
    return error.message;
  }

  throw error;
}

async function requestDeepgramSpeech(input: { slug: CourseSlug; text: string }) {
  const voiceCandidates = getVoiceCandidates(input.slug);
  const deadline = Date.now() + SPEECH_REQUEST_BUDGET_MS;
  let lastErrorMessage = "Deepgram speech generation failed.";
  for (const [index, voiceModel] of voiceCandidates.entries()) {
    const remainingMs = deadline - Date.now();
    if (remainingMs < SPEECH_TIMEOUT_FLOOR_MS) {
      break;
    }

    try {
      return await generateSpeechAttempt({
        remainingMs,
        text: input.text,
        usedFallback: index > 0,
        voiceModel,
      });
    } catch (error) {
      lastErrorMessage = getRequestErrorMessage(error);
    }
  }

  throw new Error(lastErrorMessage);
}

function getSpeechCacheKey(input: { slug: CourseSlug; text: string }) {
  return `${input.slug}:${input.text.trim()}`;
}

function trimSpeechCache() {
  while (
    speechCache.size > SPEECH_CACHE_MAX_ENTRIES ||
    speechCacheBytes > SPEECH_CACHE_MAX_BYTES
  ) {
    const oldestKey = speechCache.keys().next().value;
    if (!oldestKey) {
      break;
    }

    const oldestEntry = speechCache.get(oldestKey);
    if (oldestEntry) {
      speechCacheBytes -= oldestEntry.bytes;
    }

    speechCache.delete(oldestKey);
  }
}

function readCachedSpeech(key: string) {
  const entry = speechCache.get(key);
  if (!entry) {
    return null;
  }

  if (entry.expiresAt <= Date.now()) {
    speechCacheBytes -= entry.bytes;
    speechCache.delete(key);
    return null;
  }

  speechCache.delete(key);
  speechCache.set(key, entry);

  return {
    audio: entry.payload.slice(),
    contentType: entry.contentType,
    usedFallback: entry.usedFallback,
    voiceModel: entry.voiceModel,
  } satisfies SynthesizedSpeech;
}

function writeCachedSpeech(key: string, speech: SynthesizedSpeech) {
  if (speech.usedFallback) {
    return;
  }

  const payload = speech.audio.slice();
  const existing = speechCache.get(key);
  if (existing) {
    speechCacheBytes -= existing.bytes;
    speechCache.delete(key);
  }

  speechCache.set(key, {
    bytes: payload.byteLength,
    contentType: speech.contentType,
    expiresAt: Date.now() + SPEECH_CACHE_TTL_MS,
    payload,
    usedFallback: speech.usedFallback,
    voiceModel: speech.voiceModel,
  });
  speechCacheBytes += payload.byteLength;
  trimSpeechCache();
}

async function getSpeechAudio(input: { slug: CourseSlug; text: string }) {
  const cacheKey = getSpeechCacheKey(input);
  const cachedAudio = readCachedSpeech(cacheKey);
  if (cachedAudio) {
    return cachedAudio;
  }

  const inflightRequest = inflightSpeech.get(cacheKey);
  if (inflightRequest) {
    return inflightRequest;
  }

  const request = (async () => {
    const speech = await requestDeepgramSpeech(input);
    writeCachedSpeech(cacheKey, speech);
    return speech;
  })();

  inflightSpeech.set(cacheKey, request);

  try {
    return await request;
  } finally {
    inflightSpeech.delete(cacheKey);
  }
}

function toSpeechResponse(speech: SynthesizedSpeech) {
  const payload = new Uint8Array(speech.audio.byteLength);
  payload.set(speech.audio);

  return new Response(payload.buffer, {
    headers: {
      "Cache-Control": "private, max-age=3600, stale-while-revalidate=86400",
      "Content-Type": speech.contentType,
      "X-Tutor-Voice": speech.voiceModel,
      "X-Tutor-Voice-Fallback": speech.usedFallback ? "1" : "0",
    },
  });
}

export async function POST(request: Request) {
  try {
    const rateLimit = await enforceRateLimit({
      key: `speech:${getRequestIp(request)}`,
      limit: 30,
      windowMs: 60_000,
    });
    if (!rateLimit.success) {
      return NextResponse.json(
        { error: "Too many speech requests. Please try again shortly." },
        {
          status: 429,
          headers: {
            "Retry-After": String(Math.max(1, Math.ceil((rateLimit.resetAt - Date.now()) / 1000))),
          },
        },
      );
    }

    const body = (await request.json()) as SpeechRequestBody;
    const parsed = parseBody(body);

    if (!parsed) {
      return NextResponse.json(
        { error: "A valid course slug and text are required." },
        { status: 400 },
      );
    }

    return toSpeechResponse(await getSpeechAudio(parsed));
  } catch (error) {
    return NextResponse.json(
      {
        error:
          error instanceof Error
            ? error.message
            : "Unable to generate tutor speech right now.",
      },
      { status: 500 },
    );
  }
}
