"use client";

import { type CourseSlug } from "@/lib/course-definitions";

export type TutorAudioSegment = {
  fallbackText?: string;
  slug: CourseSlug;
  text: string;
};

type CachedSpeechAudio = {
  blob: Blob;
  expiresAt: number;
};

let activeAudio: HTMLAudioElement | null = null;
let activeObjectUrl: string | null = null;
const SPEECH_AUDIO_CACHE_TTL_MS = 60 * 60 * 1000;
const SPEECH_AUDIO_CACHE_MAX_ENTRIES = 120;
const speechAudioCache = new Map<string, CachedSpeechAudio>();
const inflightSpeechRequests = new Map<string, Promise<Blob>>();

function clearActiveAudio() {
  if (activeAudio) {
    activeAudio.pause();
    activeAudio.src = "";
    activeAudio = null;
  }

  if (activeObjectUrl) {
    URL.revokeObjectURL(activeObjectUrl);
    activeObjectUrl = null;
  }
}

function getSpeechCacheKey(segment: TutorAudioSegment) {
  return `${segment.slug}:${segment.text.trim()}`;
}

function pruneExpiredSpeechAudio(now = Date.now()) {
  for (const [key, value] of speechAudioCache.entries()) {
    if (value.expiresAt <= now) {
      speechAudioCache.delete(key);
    }
  }
}

function readCachedSpeechAudio(key: string) {
  const entry = speechAudioCache.get(key);
  if (!entry) {
    return null;
  }

  if (entry.expiresAt <= Date.now()) {
    speechAudioCache.delete(key);
    return null;
  }

  speechAudioCache.delete(key);
  speechAudioCache.set(key, entry);
  return entry.blob;
}

function writeCachedSpeechAudio(key: string, blob: Blob) {
  pruneExpiredSpeechAudio();
  speechAudioCache.delete(key);
  speechAudioCache.set(key, {
    blob,
    expiresAt: Date.now() + SPEECH_AUDIO_CACHE_TTL_MS,
  });

  while (speechAudioCache.size > SPEECH_AUDIO_CACHE_MAX_ENTRIES) {
    const oldestKey = speechAudioCache.keys().next().value;
    if (!oldestKey) {
      break;
    }

    speechAudioCache.delete(oldestKey);
  }
}

function shouldCacheSpeechAudio(response: Response) {
  return response.headers.get("X-Tutor-Voice-Fallback") !== "1";
}

async function fetchSpeechAudioForText(segment: TutorAudioSegment, text: string) {
  const normalizedText = text.trim();
  const cacheKey = getSpeechCacheKey({ ...segment, text: normalizedText });
  const cachedAudio = readCachedSpeechAudio(cacheKey);
  if (cachedAudio) {
    return cachedAudio;
  }

  const inflightRequest = inflightSpeechRequests.get(cacheKey);
  if (inflightRequest) {
    return inflightRequest;
  }

  const request = (async () => {
    const response = await fetch("/api/speech", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        slug: segment.slug,
        text: normalizedText,
      }),
    });

    if (!response.ok) {
      throw new Error("Tutor audio is unavailable right now. Please try again.");
    }

    const audioBlob = await response.blob();
    if (shouldCacheSpeechAudio(response)) {
      writeCachedSpeechAudio(cacheKey, audioBlob);
    }
    return audioBlob;
  })();

  inflightSpeechRequests.set(cacheKey, request);

  try {
    return await request;
  } finally {
    inflightSpeechRequests.delete(cacheKey);
  }
}

async function fetchSpeechAudio(segment: TutorAudioSegment) {
  try {
    return await fetchSpeechAudioForText(segment, segment.text);
  } catch (error) {
    const fallbackText = segment.fallbackText?.trim();
    if (!fallbackText || fallbackText === segment.text.trim()) {
      throw error;
    }

    return fetchSpeechAudioForText(segment, fallbackText);
  }
}

async function playBlob(blob: Blob) {
  clearActiveAudio();

  const objectUrl = URL.createObjectURL(blob);
  const audio = new Audio(objectUrl);
  audio.volume = 1;
  activeAudio = audio;
  activeObjectUrl = objectUrl;

  return new Promise<void>((resolve, reject) => {
    audio.onended = () => {
      clearActiveAudio();
      resolve();
    };
    audio.onerror = () => {
      clearActiveAudio();
      reject(new Error("Unable to play tutor audio."));
    };
    void audio.play().catch((error) => {
      clearActiveAudio();
      reject(error);
    });
  });
}

export async function playTutorAudioSequence(segments: TutorAudioSegment[]) {
  for (const segment of segments) {
    const audioBlob = await fetchSpeechAudio(segment);
    await playBlob(audioBlob);
  }
}
