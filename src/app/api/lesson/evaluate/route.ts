import { NextResponse } from "next/server";
import { courseDefinitions, type CourseSlug } from "@/lib/course-definitions";
import { getLessonAiEnv } from "@/lib/lesson-ai-env";
import {
  buildLessonEvaluation,
  scoreLessonWithOpenAi,
  transcribeWithDeepgram,
} from "@/lib/lesson-evaluation";

function isCourseSlug(value: string): value is CourseSlug {
  return value in courseDefinitions;
}

function findLesson(input: {
  lessonId: string;
  moduleId: string;
  slug: CourseSlug;
}) {
  const course = courseDefinitions[input.slug];
  const courseModule = course.framework.levels
    .flatMap((level) => level.modules)
    .find((item) => item.id === input.moduleId);

  return (
    courseModule?.lessons.find((lesson) => lesson.id === input.lessonId) ?? null
  );
}

export async function POST(request: Request) {
  try {
    const formData = await request.formData();
    const slug = String(formData.get("slug") ?? "");
    const moduleId = String(formData.get("moduleId") ?? "");
    const lessonId = String(formData.get("lessonId") ?? "");
    const audioFile = formData.get("audio");

    if (!isCourseSlug(slug) || !(audioFile instanceof File)) {
      return NextResponse.json(
        { error: "Invalid lesson evaluation request." },
        { status: 400 },
      );
    }

    const lesson = findLesson({ lessonId, moduleId, slug });
    if (!lesson) {
      return NextResponse.json({ error: "Lesson not found." }, { status: 404 });
    }

    const env = getLessonAiEnv();
    const deepgram = await transcribeWithDeepgram({
      audioBuffer: await audioFile.arrayBuffer(),
      contentType: audioFile.type || "audio/webm",
      deepgramKey: env.deepgramKey,
      deepgramModel: env.deepgramModel,
    });
    const scorecard = await scoreLessonWithOpenAi({
      deepgram,
      lesson,
      openAiKey: env.openAiKey,
      openAiModel: env.openAiModel,
      slug,
    });

    return NextResponse.json(buildLessonEvaluation(deepgram, scorecard));
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Lesson evaluation failed.";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
