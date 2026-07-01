import { NextResponse } from "next/server";
import { enforceRateLimit, getRequestIp } from "@/lib/api-rate-limit";
import {
  courseSlugs,
  type CourseLesson,
  type CourseSlug,
} from "@/lib/course-definitions";
import { loadCourseDefinition } from "@/lib/course-loader";
import { getLessonAiEnv } from "@/lib/lesson-ai-env";
import {
  buildLessonEvaluation,
  scoreLessonWithOpenAi,
  transcribeWithDeepgram,
} from "@/lib/lesson-evaluation";

export const runtime = "nodejs";
export const maxDuration = 30;

const MAX_AUDIO_FILE_SIZE = 8 * 1024 * 1024;

type LessonLookupError = "course_unavailable" | "lesson_not_found";
type LessonLookupResult =
  | { error: LessonLookupError }
  | { lesson: CourseLesson };

function isCourseSlug(value: string): value is CourseSlug {
  return courseSlugs.includes(value as CourseSlug);
}

async function findLesson(input: {
  lessonId: string;
  moduleId: string;
  slug: CourseSlug;
}): Promise<LessonLookupResult> {
  const course = await loadCourseDefinition(input.slug);
  if (!course) {
    return { error: "course_unavailable" } as const;
  }

  const courseModule = course.framework.levels
    .flatMap((level) => level.modules)
    .find((item) => item.id === input.moduleId);

  const lesson =
    courseModule?.lessons.find((item) => item.id === input.lessonId) ?? null;

  if (!lesson) {
    return { error: "lesson_not_found" } as const;
  }

  return { lesson } as const;
}

async function parseEvaluationRequest(request: Request) {
  const formData = await request.formData();
  const slug = String(formData.get("slug") ?? "");
  const moduleId = String(formData.get("moduleId") ?? "");
  const lessonId = String(formData.get("lessonId") ?? "");
  const audioFile = formData.get("audio");

  if (
    !isCourseSlug(slug) ||
    !(audioFile instanceof File) ||
    audioFile.size <= 0 ||
    audioFile.size > MAX_AUDIO_FILE_SIZE
  ) {
    return { errorResponse: invalidRequestResponse() } as const;
  }

  return { audioFile, lessonId, moduleId, slug } as const;
}

function invalidRequestResponse() {
  return NextResponse.json(
    { error: "Invalid lesson evaluation request." },
    { status: 400 },
  );
}

function lookupErrorResponse(error: LessonLookupError) {
  if (error === "course_unavailable") {
    return NextResponse.json(
      { error: "Course data is not available from the database yet." },
      { status: 503 },
    );
  }

  return NextResponse.json({ error: "Lesson not found." }, { status: 404 });
}

function hasLookupError(lookup: LessonLookupResult) {
  return "error" in lookup;
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

function enforceLessonEvaluationLimit(request: Request) {
  const rateLimit = enforceRateLimit({
    key: `lesson-evaluate:${getRequestIp(request)}`,
    limit: 12,
    windowMs: 60_000,
  });
  if (rateLimit.success) {
    return null;
  }

  return createRateLimitResponse(
    "Too many lesson evaluations. Please try again shortly.",
    rateLimit.resetAt,
  );
}

export async function POST(request: Request) {
  try {
    const rateLimitResponse = enforceLessonEvaluationLimit(request);
    if (rateLimitResponse) {
      return rateLimitResponse;
    }

    const parsed = await parseEvaluationRequest(request);
    if ("errorResponse" in parsed) {
      return parsed.errorResponse;
    }

    const lookup = await findLesson(parsed);
    if (hasLookupError(lookup)) {
      return lookupErrorResponse(lookup.error);
    }

    const env = getLessonAiEnv();
    const deepgram = await transcribeWithDeepgram({
      audioBuffer: await parsed.audioFile.arrayBuffer(),
      contentType: parsed.audioFile.type || "audio/webm",
      deepgramKey: env.deepgramKey,
      deepgramModel: env.deepgramModel,
      slug: parsed.slug,
    });
    const scorecard = await scoreLessonWithOpenAi({
      deepgram,
      lesson: lookup.lesson,
      openAiKey: env.openAiKey,
      openAiModel: env.openAiModel,
      slug: parsed.slug,
    });

    return NextResponse.json(
      buildLessonEvaluation(deepgram, scorecard, lookup.lesson, parsed.slug),
    );
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Lesson evaluation failed.";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
