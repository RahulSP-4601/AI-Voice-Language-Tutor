"use client";

import { type RefObject, useEffect, useRef, useState } from "react";
import { type CourseSlug } from "@/lib/course-definitions";
import { playCourseSpeech, speechSynthesisSupported } from "@/lib/browser-speech";
import { playTutorAudioSequence } from "@/lib/tutor-audio";

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

function useRecognitionLifecycle(input: {
  onTranscript: (value: string) => void;
  recognitionCtor: ReturnType<typeof getSpeechRecognitionCtor>;
  recognitionRef: RefObject<RecognitionShape | null>;
  setIsListening: (value: boolean) => void;
  slug: CourseSlug;
}) {
  const {
    onTranscript,
    recognitionCtor,
    recognitionRef,
    setIsListening,
    slug,
  } = input;

  useEffect(() => {
    if (!recognitionCtor) {
      return;
    }

    const recognition = new recognitionCtor() as RecognitionShape;
    bindRecognition({
      onTranscript,
      recognition,
      setIsListening,
      slug,
    });
    recognitionRef.current = recognition;

    return () => {
      recognition.abort();
      recognitionRef.current = null;
    };
  }, [onTranscript, recognitionCtor, recognitionRef, setIsListening, slug]);
}

function createPhrasePlayer(slug: CourseSlug) {
  return async (phrase: string, fallbackPhrase?: string) => {
    await playTutorAudioSequence([
      {
        fallbackText: fallbackPhrase,
        slug,
        text: phrase,
      },
    ]).catch(() => {
      if (speechSynthesisSupported()) {
        playCourseSpeech({
          fallbackText: fallbackPhrase,
          primaryText: phrase,
          slug,
        });
      }
    });
  };
}

export function useLessonSpeech(
  slug: CourseSlug,
  onTranscript: (value: string) => void,
) {
  const recognitionRef = useRef<RecognitionShape | null>(null);
  const [isListening, setIsListening] = useState(false);
  const recognitionCtor = getSpeechRecognitionCtor();
  const supported = Boolean(recognitionCtor);
  const playPhrase = createPhrasePlayer(slug);

  useRecognitionLifecycle({
    onTranscript,
    recognitionCtor,
    recognitionRef,
    setIsListening,
    slug,
  });

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

  return { isListening, playPhrase, startListening, stopListening, supported };
}

declare global {
  interface Window {
    SpeechRecognition?: new () => RecognitionShape;
    webkitSpeechRecognition?: new () => RecognitionShape;
  }
}
