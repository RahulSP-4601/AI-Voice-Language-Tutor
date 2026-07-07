"use client";

import { useRef, useState } from "react";
import { type CourseSlug } from "@/lib/course-definitions";
import {
  playTutorAudioSequence,
  type TutorAudioSegment,
} from "@/lib/tutor-audio";

function toErrorMessage(error: unknown) {
  if (error instanceof Error && error.message.trim()) {
    return error.message;
  }

  return "Tutor audio is unavailable right now. Please try again.";
}

export function useTutorSpeechPlayback(slug: CourseSlug) {
  const isPlayingRef = useRef(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [playbackError, setPlaybackError] = useState("");

  async function playSegments(segments: Omit<TutorAudioSegment, "slug">[]) {
    if (isPlayingRef.current) {
      return;
    }

    isPlayingRef.current = true;
    setPlaybackError("");
    setIsPlaying(true);

    try {
      await playTutorAudioSequence(
        segments.map((segment) => ({
          ...segment,
          slug,
        })),
      );
    } catch (error) {
      setPlaybackError(toErrorMessage(error));
    } finally {
      isPlayingRef.current = false;
      setIsPlaying(false);
    }
  }

  async function playPhrase(text: string, fallbackText?: string) {
    await playSegments([
      {
        fallbackText,
        text,
      },
    ]);
  }

  return {
    isPlaying,
    playPhrase,
    playSegments,
    playbackError,
  };
}
