"use client";

import { type CourseSlug } from "@/lib/course-definitions";
import { getSpeechSupport } from "@/lib/language-speech";
import { generatePronunciationHint, kanaToRomaji } from "@/lib/pronunciation-hint";

function hasJapaneseCharacters(value: string) {
  return /[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff々]/u.test(value);
}

function hasKana(value: string) {
  return /[\u3040-\u30ff]/u.test(value);
}

function voicesForLanguage(lang: string) {
  return window.speechSynthesis
    .getVoices()
    .filter((voice) => voice.lang.toLowerCase().startsWith(lang.toLowerCase()));
}

function pickVoice(lang: string) {
  const matches = voicesForLanguage(lang);
  return matches[0] ?? null;
}

function buildUtterance(text: string, lang: string, voice?: SpeechSynthesisVoice | null) {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = lang;
  if (voice) {
    utterance.voice = voice;
  }
  return utterance;
}

function normalizeJapaneseFallbackText(value: string) {
  if (hasKana(value)) {
    return generatePronunciationHint(value);
  }

  return generatePronunciationHint(kanaToRomaji(value));
}

function buildPrimaryUtterance(input: {
  fallbackText?: string;
  primaryText: string;
  slug: CourseSlug;
}) {
  const lang = getSpeechSupport(input.slug).speechSynthesisLanguage;
  const matchingVoice = pickVoice(lang);

  if (matchingVoice) {
    return buildUtterance(input.primaryText, lang, matchingVoice);
  }

  const fallbackText = input.fallbackText?.trim();
  if (
    input.slug === "japanese" &&
    fallbackText &&
    fallbackText !== input.primaryText &&
    hasJapaneseCharacters(input.primaryText)
  ) {
    return buildUtterance(normalizeJapaneseFallbackText(fallbackText), "en-US");
  }

  return buildUtterance(input.primaryText, lang);
}

export function playCourseSpeech(input: {
  fallbackText?: string;
  primaryText: string;
  secondaryText?: string;
  slug: CourseSlug;
}) {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) {
    return;
  }

  const primary = buildPrimaryUtterance(input);
  const secondary = input.secondaryText?.trim()
    ? buildUtterance(input.secondaryText, "en-US")
    : null;

  window.speechSynthesis.cancel();
  if (secondary) {
    primary.onend = () => window.speechSynthesis.speak(secondary);
  }
  window.speechSynthesis.speak(primary);
}

export function speechSynthesisSupported() {
  return typeof window !== "undefined" && "speechSynthesis" in window;
}
