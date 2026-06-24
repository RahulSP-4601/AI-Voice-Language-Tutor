"use client";

import { useState } from "react";
import { type CourseLesson, type CourseSlug, type LessonEvaluation } from "@/lib/course-definitions";

export function useLessonEvaluation() {
  const [evaluation, setEvaluation] = useState<LessonEvaluation | null>(null);
  const [error, setError] = useState("");
  const [isEvaluating, setIsEvaluating] = useState(false);

  async function evaluate(input: {
    audioBlob: Blob;
    lesson: CourseLesson;
    moduleId: string;
    slug: CourseSlug;
  }) {
    setError("");
    setIsEvaluating(true);

    try {
      const formData = new FormData();
      formData.set("audio", input.audioBlob, `${input.lesson.id}.webm`);
      formData.set("lessonId", input.lesson.id);
      formData.set("moduleId", input.moduleId);
      formData.set("slug", input.slug);
      const response = await fetch("/api/lesson/evaluate", {
        body: formData,
        method: "POST",
      });

      if (!response.ok) {
        const payload = (await response.json()) as { error?: string };
        throw new Error(payload.error ?? "Lesson evaluation failed.");
      }

      const payload = (await response.json()) as LessonEvaluation;
      setEvaluation(payload);
      return payload;
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Lesson evaluation failed.";
      setError(message);
      return null;
    } finally {
      setIsEvaluating(false);
    }
  }

  return { error, evaluate, evaluation, isEvaluating, setEvaluation };
}
