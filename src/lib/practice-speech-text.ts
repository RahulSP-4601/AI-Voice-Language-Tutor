import { type PracticeCard } from "@/lib/module-practice";
import { generatePronunciationHint } from "@/lib/pronunciation-hint";

const JAPANESE_NUMBER_OVERRIDES: Record<string, string> = {
  九: "きゅう",
  七: "なな",
  四: "よん",
  何: "なに",
};

function hasJapaneseCharacters(value: string) {
  return /[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff々]/u.test(value);
}

function splitReadingVariants(value: string) {
  return value
    .split("/")
    .map((part) => part.trim())
    .filter(Boolean);
}

function normalizeReadingValue(value: string) {
  return value.replace(/\s+/g, " ").trim();
}

function resolvePreferredReading(card: PracticeCard) {
  const explicitOverride = JAPANESE_NUMBER_OVERRIDES[card.japanese];
  if (explicitOverride) {
    return explicitOverride;
  }

  const variants = splitReadingVariants(card.reading);
  if (!variants.length) {
    return normalizeReadingValue(card.reading);
  }

  const japaneseVariant = variants.find(hasJapaneseCharacters);
  if (japaneseVariant) {
    return normalizeReadingValue(japaneseVariant);
  }

  return normalizeReadingValue(variants[0]);
}

export function resolvePracticeDisplayReading(card: PracticeCard) {
  return resolvePreferredReading(card);
}

export function resolvePracticePhoneticHint(card: PracticeCard) {
  return generatePronunciationHint(resolvePreferredReading(card));
}

export function resolvePracticeSpeechText(card: PracticeCard) {
  if (hasJapaneseCharacters(card.reading)) {
    return resolvePreferredReading(card);
  }

  return card.japanese;
}

export function resolvePracticeSpeechFallback(card: PracticeCard) {
  const preferredReading = resolvePreferredReading(card);
  if (preferredReading && preferredReading !== card.japanese) {
    return preferredReading;
  }

  return card.reading;
}
