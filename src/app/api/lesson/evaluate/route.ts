import { NextResponse } from "next/server";
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

  if (!isCourseSlug(slug) || !(audioFile instanceof File)) {
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

export async function POST(request: Request) {
  try {
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
    });
    const scorecard = await scoreLessonWithOpenAi({
      deepgram,
      lesson: lookup.lesson,
      openAiKey: env.openAiKey,
      openAiModel: env.openAiModel,
      slug: parsed.slug,
    });

    return NextResponse.json(
      buildLessonEvaluation(deepgram, scorecard, lookup.lesson),
    );
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Lesson evaluation failed.";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
