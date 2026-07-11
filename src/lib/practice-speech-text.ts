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

function hasKanaSoundCharacters(value: string) {
  return /[\u3040-\u30ffー]/u.test(value);
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

function normalizeJapaneseSpeechSource(value: string) {
  return normalizeReadingValue(value)
    .replace(/[（(][^）)]{1,4}[）)]/g, "")
    .replace(/[・]/g, "")
    .replace(/[…。｡]+/g, "")
    .trim();
}

function deriveReadingFromJapanese(value: string) {
  const normalized = normalizeJapaneseSpeechSource(value);
  if (!normalized || /[\u3400-\u4dbf\u4e00-\u9fff々]/u.test(normalized)) {
    return "";
  }

  return hasKanaSoundCharacters(normalized) ? normalized : "";
}

function resolvePreferredReading(card: PracticeCard) {
  const explicitOverride = JAPANESE_NUMBER_OVERRIDES[card.japanese];
  if (explicitOverride) {
    return explicitOverride;
  }

  const variants = splitReadingVariants(card.reading);
  if (!variants.length) {
    return deriveReadingFromJapanese(card.japanese);
  }

  const japaneseVariant = variants.find(hasJapaneseCharacters);
  if (japaneseVariant) {
    return normalizeReadingValue(japaneseVariant);
  }

  const derivedReading = deriveReadingFromJapanese(card.japanese);
  if (derivedReading) {
    return derivedReading;
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
  const preferredReading = resolvePreferredReading(card);
  if (hasJapaneseCharacters(preferredReading)) {
    return preferredReading;
  }

  return card.japanese;
}

export function resolvePracticeSpeechFallback(card: PracticeCard) {
  const preferredReading = resolvePreferredReading(card);
  const rawReading = normalizeReadingValue(card.reading);
  if (rawReading && rawReading !== preferredReading) {
    return rawReading;
  }

  if (preferredReading) {
    return `${preferredReading}。`;
  }

  return card.reading;
}
