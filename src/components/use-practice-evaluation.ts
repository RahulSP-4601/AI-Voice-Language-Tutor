"use client";

import { useState } from "react";
import { type CourseSlug, type LessonEvaluation } from "@/lib/course-definitions";
import { type PracticeCard } from "@/lib/module-practice";

export function usePracticeEvaluation() {
  const [error, setError] = useState("");
  const [isEvaluating, setIsEvaluating] = useState(false);

  async function evaluate(input: {
    audioBlob: Blob;
    item: PracticeCard;
    slug: CourseSlug;
  }) {
    setError("");
    setIsEvaluating(true);

    try {
      const formData = buildFormData(input);
      const response = await fetch("/api/practice/evaluate", {
        body: formData,
        method: "POST",
      });
      const payload = (await response.json()) as LessonEvaluation & { error?: string };
      if (!response.ok) {
        throw new Error(payload.error ?? "Practice evaluation failed.");
      }
      return payload;
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Practice evaluation failed.";
      setError(message);
      return null;
    } finally {
      setIsEvaluating(false);
    }
  }

  return { error, evaluate, isEvaluating };
}

function buildFormData(input: {
  audioBlob: Blob;
  item: PracticeCard;
  slug: CourseSlug;
}) {
  const formData = new FormData();
  formData.set("audio", input.audioBlob, `${input.item.id}.webm`);
  formData.set("english", input.item.english);
  formData.set("phoneticHint", input.item.phoneticHint);
  formData.set("japanese", input.item.japanese);
  formData.set("reading", input.item.reading);
  formData.set("slug", input.slug);
  return formData;
}
