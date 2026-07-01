import { NextResponse } from "next/server";
import { enforceRateLimit, getRequestIp } from "@/lib/api-rate-limit";
import {
  courseSlugs,
  type CourseLesson,
  type CourseSlug,
} from "@/lib/course-definitions";
import { getLessonAiEnv } from "@/lib/lesson-ai-env";
import {
  buildLessonEvaluation,
  scoreLessonWithOpenAi,
  transcribeWithDeepgram,
} from "@/lib/lesson-evaluation";

export const runtime = "nodejs";
export const maxDuration = 30;

const MAX_AUDIO_FILE_SIZE = 8 * 1024 * 1024;

function isCourseSlug(value: string): value is CourseSlug {
  return courseSlugs.includes(value as CourseSlug);
}

async function parsePracticeRequest(request: Request) {
  const formData = await request.formData();
  const slug = String(formData.get("slug") ?? "");
  const japanese = String(formData.get("japanese") ?? "");
  const reading = String(formData.get("reading") ?? "");
  const phoneticHint = String(formData.get("phoneticHint") ?? "");
  const english = String(formData.get("english") ?? "");
  const audioFile = formData.get("audio");

  if (
    !isCourseSlug(slug) ||
    !(audioFile instanceof File) ||
    audioFile.size <= 0 ||
    audioFile.size > MAX_AUDIO_FILE_SIZE ||
    !japanese ||
    !reading
  ) {
    return null;
  }

  return { audioFile, english, japanese, phoneticHint, reading, slug };
}

function buildPracticeLesson(input: {
  english: string;
  japanese: string;
  phoneticHint: string;
  reading: string;
}) {
  return {
    acceptableResponses: [input.japanese, input.reading, input.phoneticHint].filter(Boolean),
    demoPhrase: input.japanese,
    durationMinutes: 1,
    feedback: {
      correctionStyle: "Keep the correction short, warm, and beginner-friendly in Japanese.",
      focus: "Clear spoken practice",
      retryCue: "Try one cleaner repetition.",
      successSignal: "The learner can say the target naturally.",
    },
    id: "practice-card",
    learnerOutcome: `Learner can say ${input.english || input.reading}.`,
    mode: "speaking",
    replyPrompt: `Say ${input.reading} clearly once. A close beginner pronunciation can still pass.`,
    targetPattern: input.reading,
    title: input.english || input.reading,
    turns: [],
  } satisfies CourseLesson;
}

function invalidRequestResponse() {
  return NextResponse.json(
    { error: "Invalid practice evaluation request." },
    { status: 400 },
  );
}

function createRateLimitResponse(message: string, resetAt: number) {
  return NextResponse.json(
    { error: message },
    {
      status: 429,
      headers: {
        "Retry-After": String(Math.max(1, Math.ceil((resetAt - Date.now()) / 1000))),
      },
    },
  );
}

function enforcePracticeEvaluationLimit(request: Request) {
  const rateLimit = enforceRateLimit({
    key: `practice-evaluate:${getRequestIp(request)}`,
    limit: 12,
    windowMs: 60_000,
  });
  if (rateLimit.success) {
    return null;
  }

  return createRateLimitResponse(
    "Too many practice evaluations. Please try again shortly.",
    rateLimit.resetAt,
  );
}

export async function POST(request: Request) {
  try {
    const rateLimitResponse = enforcePracticeEvaluationLimit(request);
    if (rateLimitResponse) {
      return rateLimitResponse;
    }

    const parsed = await parsePracticeRequest(request);
    if (!parsed) {
      return invalidRequestResponse();
    }

    const env = getLessonAiEnv();
    const lesson = buildPracticeLesson(parsed);
    const deepgram = await transcribeWithDeepgram({
      audioBuffer: await parsed.audioFile.arrayBuffer(),
      contentType: parsed.audioFile.type || "audio/webm",
      deepgramKey: env.deepgramKey,
      deepgramModel: env.deepgramModel,
      slug: parsed.slug,
    });
    const scorecard = await scoreLessonWithOpenAi({
      deepgram,
      lesson,
      openAiKey: env.openAiKey,
      openAiModel: env.openAiModel,
      slug: parsed.slug,
    });

    return NextResponse.json(
      buildLessonEvaluation(deepgram, scorecard, lesson, parsed.slug),
    );
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Practice evaluation failed.";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
