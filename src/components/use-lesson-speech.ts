"use client";

import { useEffect, useRef, useState } from "react";
import { type CourseSlug } from "@/lib/course-definitions";

type RecognitionShape = {
  abort: () => void;
  lang: string;
  onend: null | (() => void);
  onerror: null | (() => void);
  onresult: null | ((event: SpeechRecognitionEventLike) => void);
  start: () => void;
};

type SpeechRecognitionEventLike = {
  results: ArrayLike<ArrayLike<{ transcript: string }>>;
};

function getSpeechLanguage(slug: CourseSlug) {
  if (slug === "japanese") return "ja-JP";
  if (slug === "german") return "de-DE";
  if (slug === "spanish") return "es-ES";
  if (slug === "french") return "fr-FR";
  return "en-US";
}

export function useLessonSpeech(
  slug: CourseSlug,
  onTranscript: (value: string) => void,
) {
  const recognitionRef = useRef<RecognitionShape | null>(null);
  const [isListening, setIsListening] = useState(false);
  const SpeechRecognitionCtor =
    typeof window === "undefined"
      ? undefined
      : window.SpeechRecognition ?? window.webkitSpeechRecognition;
  const supported = Boolean(SpeechRecognitionCtor);

  useEffect(() => {
    if (!SpeechRecognitionCtor) {
      return;
    }

    const recognition = new SpeechRecognitionCtor() as RecognitionShape;
    recognition.lang = getSpeechLanguage(slug);
    recognition.onresult = (event) => {
      const text = event.results[0]?.[0]?.transcript ?? "";
      onTranscript(text);
    };
    recognition.onend = () => setIsListening(false);
    recognition.onerror = () => setIsListening(false);
    recognitionRef.current = recognition;

    return () => recognition.abort();
  }, [SpeechRecognitionCtor, onTranscript, slug]);

  function startListening() {
    recognitionRef.current?.start();
    setIsListening(true);
  }

  function playPhrase(phrase: string) {
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(phrase);
    utterance.lang = getSpeechLanguage(slug);
    window.speechSynthesis.speak(utterance);
  }

  return { isListening, playPhrase, startListening, supported };
}

declare global {
  interface Window {
    SpeechRecognition?: new () => RecognitionShape;
    webkitSpeechRecognition?: new () => RecognitionShape;
  }
}
