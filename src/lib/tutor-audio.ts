"use client";

import { playCourseSpeech } from "@/lib/browser-speech";
import { type CourseSlug } from "@/lib/course-definitions";

type TutorAudioSegment = {
  fallbackText?: string;
  slug: CourseSlug;
  text: string;
};

let activeAudio: HTMLAudioElement | null = null;
let activeObjectUrl: string | null = null;

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

async function fetchSpeechAudio(segment: TutorAudioSegment) {
  const response = await fetch("/api/speech", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      slug: segment.slug,
      text: segment.text,
    }),
  });

  if (!response.ok) {
    throw new Error("Tutor audio request failed.");
  }

  return response.blob();
}

function playBlob(blob: Blob) {
  clearActiveAudio();

  const objectUrl = URL.createObjectURL(blob);
  const audio = new Audio(objectUrl);
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

function playFallback(segment: TutorAudioSegment) {
  playCourseSpeech({
    fallbackText: segment.fallbackText,
    primaryText: segment.text,
    slug: segment.slug,
  });
}

export async function playTutorAudioSequence(segments: TutorAudioSegment[]) {
  for (const segment of segments) {
    try {
      const audioBlob = await fetchSpeechAudio(segment);
      await playBlob(audioBlob);
    } catch {
      playFallback(segment);
      break;
    }
  }
}
