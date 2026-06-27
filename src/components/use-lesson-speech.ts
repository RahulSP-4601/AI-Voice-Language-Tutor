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
  stop?: () => void;
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

function getSpeechRecognitionCtor() {
  if (typeof window === "undefined") {
    return undefined;
  }

  return window.SpeechRecognition ?? window.webkitSpeechRecognition;
}

function bindRecognition(input: {
  onTranscript: (value: string) => void;
  recognition: RecognitionShape;
  setIsListening: (value: boolean) => void;
  slug: CourseSlug;
}) {
  input.recognition.lang = getSpeechLanguage(input.slug);
  input.recognition.onresult = (event) => {
    const text = event.results[0]?.[0]?.transcript ?? "";
    input.onTranscript(text);
  };
  input.recognition.onend = () => input.setIsListening(false);
  input.recognition.onerror = () => input.setIsListening(false);
}

function stopRecognition(recognition: RecognitionShape, setIsListening: (value: boolean) => void) {
  if (recognition.stop) {
    recognition.stop();
    return;
  }

  recognition.abort();
  setIsListening(false);
}

export function useLessonSpeech(
  slug: CourseSlug,
  onTranscript: (value: string) => void,
) {
  const recognitionRef = useRef<RecognitionShape | null>(null);
  const [isListening, setIsListening] = useState(false);
  const SpeechRecognitionCtor = getSpeechRecognitionCtor();
  const supported = Boolean(SpeechRecognitionCtor);

  useEffect(() => {
    if (!SpeechRecognitionCtor) {
      return;
    }

    const recognition = new SpeechRecognitionCtor() as RecognitionShape;
    bindRecognition({ onTranscript, recognition, setIsListening, slug });
    recognitionRef.current = recognition;

    return () => {
      recognition.abort();
      recognitionRef.current = null;
    };
  }, [SpeechRecognitionCtor, onTranscript, slug]);

  function startListening() {
    if (!recognitionRef.current) {
      return;
    }

    recognitionRef.current.start();
    setIsListening(true);
  }

  function stopListening() {
    if (!recognitionRef.current) {
      return;
    }

    stopRecognition(recognitionRef.current, setIsListening);
  }

  function playPhrase(phrase: string) {
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(phrase);
    utterance.lang = getSpeechLanguage(slug);
    window.speechSynthesis.speak(utterance);
  }

  return { isListening, playPhrase, startListening, stopListening, supported };
}

declare global {
  interface Window {
    SpeechRecognition?: new () => RecognitionShape;
    webkitSpeechRecognition?: new () => RecognitionShape;
  }
}
