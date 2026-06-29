import { type CourseSlug } from "@/lib/course-definitions";
import { kanaToRomaji } from "@/lib/pronunciation-hint";

type SpeechSupport = {
  deepgramLanguage: string;
  feedbackLanguage: string;
  label: string;
  passScore: number;
  speechSynthesisLanguage: string;
};

type SpeechScoreBand = {
  accuracyScore: number;
  fluencyScore: number;
  matchedExpectedPhrase: boolean;
  pronunciationScore: number;
  shouldAdvance: boolean;
  similarity: number;
};

const SUPPORT: Record<CourseSlug, SpeechSupport> = {
  english: {
    deepgramLanguage: "en",
    feedbackLanguage: "simple English",
    label: "English",
    passScore: 75,
    speechSynthesisLanguage: "en-US",
  },
  french: {
    deepgramLanguage: "fr",
    feedbackLanguage: "simple French",
    label: "French",
    passScore: 75,
    speechSynthesisLanguage: "fr-FR",
  },
  german: {
    deepgramLanguage: "de",
    feedbackLanguage: "simple German",
    label: "German",
    passScore: 75,
    speechSynthesisLanguage: "de-DE",
  },
  japanese: {
    deepgramLanguage: "ja",
    feedbackLanguage: "simple Japanese",
    label: "Japanese",
    passScore: 75,
    speechSynthesisLanguage: "ja-JP",
  },
  spanish: {
    deepgramLanguage: "es",
    feedbackLanguage: "simple Spanish",
    label: "Spanish",
    passScore: 75,
    speechSynthesisLanguage: "es-ES",
  },
};

const JAPANESE_SOUND_REPLACEMENTS: Array<[RegExp, string]> = [
  [/eetchi/g, "iti"],
  [/eechi/g, "iti"],
  [/echee/g, "iti"],
  [/itchy/g, "iti"],
  [/itchi/g, "iti"],
  [/itch/g, "iti"],
  [/icchi/g, "iti"],
  [/ichi/g, "iti"],
  [/shee/g, "si"],
  [/shi/g, "si"],
  [/shy/g, "si"],
  [/chee/g, "ti"],
  [/chi/g, "ti"],
  [/chy/g, "ti"],
  [/tchy/g, "ti"],
  [/jee/g, "zi"],
  [/ji/g, "zi"],
  [/tsoo/g, "tu"],
  [/tsu/g, "tu"],
  [/dzu/g, "zu"],
];

export function getSpeechSupport(slug: CourseSlug) {
  return SUPPORT[slug];
}

export function scoreSpeechAttempt(
  slug: CourseSlug,
  transcript: string,
  candidates: string[],
) {
  const band = buildSpeechScoreBand(slug, transcript, candidates, 1);
  return Math.round(
    (band.pronunciationScore + band.accuracyScore + band.fluencyScore) / 3,
  );
}

export function buildSpeechScoreBand(
  slug: CourseSlug,
  transcript: string,
  candidates: string[],
  confidence: number,
) {
  const similarity = getBestSpeechSimilarity(slug, transcript, candidates);
  const blended = similarity * 0.9 + Math.max(confidence, 0.35) * 0.1;

  if (blended >= 0.96) return createSpeechScoreBand(98, 97, 93, true, true, blended);
  if (blended >= 0.9) return createSpeechScoreBand(94, 92, 88, true, true, blended);
  if (blended >= 0.82) return createSpeechScoreBand(87, 85, 80, true, true, blended);
  if (blended >= 0.74) return createSpeechScoreBand(79, 77, 74, true, true, blended);
  if (blended >= 0.64) return createSpeechScoreBand(69, 67, 63, false, false, blended);
  if (blended >= 0.52) return createSpeechScoreBand(58, 56, 52, false, false, blended);
  return createSpeechScoreBand(0, 0, 0, false, false, blended);
}

export function getBestSpeechSimilarity(
  slug: CourseSlug,
  transcript: string,
  candidates: string[],
) {
  const transcriptForms = toComparableForms(slug, transcript);
  if (!transcriptForms.length) return 0;

  return candidates.reduce((best, candidate) => {
    const candidateForms = toComparableForms(slug, candidate);
    const similarity = bestFormSimilarity(transcriptForms, candidateForms);
    return Math.max(best, similarity);
  }, 0);
}

function createSpeechScoreBand(
  pronunciationScore: number,
  accuracyScore: number,
  fluencyScore: number,
  matchedExpectedPhrase: boolean,
  shouldAdvance: boolean,
  similarity: number,
) {
  return {
    accuracyScore,
    fluencyScore,
    matchedExpectedPhrase,
    pronunciationScore,
    shouldAdvance,
    similarity: Number(similarity.toFixed(2)),
  } satisfies SpeechScoreBand;
}

function toComparableForms(slug: CourseSlug, value: string) {
  const source = normalizeWhitespace(value);
  if (!source) return [];

  if (slug === "japanese") {
    return uniqueStrings([
      compactKana(source),
      compactLatin(japaneseLatinForm(source)),
      compactLatin(japaneseSoundForm(source)),
      compactLatin(normalizeAscii(source)),
    ]);
  }

  return uniqueStrings([
    compactLatin(normalizeCourseText(slug, source)),
    compactLatin(normalizeCourseSound(slug, source)),
  ]);
}

function bestFormSimilarity(leftForms: string[], rightForms: string[]) {
  return leftForms.reduce((best, left) => {
    const current = rightForms.reduce((innerBest, right) => {
      return Math.max(innerBest, phraseSimilarity(left, right));
    }, 0);
    return Math.max(best, current);
  }, 0);
}

function normalizeCourseText(slug: CourseSlug, value: string) {
  const folded = normalizeAscii(value);
  if (slug === "german") return normalizeGermanText(folded);
  return folded;
}

function normalizeCourseSound(slug: CourseSlug, value: string) {
  if (slug === "english") return normalizeEnglishSound(value);
  if (slug === "german") return normalizeGermanSound(value);
  if (slug === "spanish") return normalizeSpanishSound(value);
  if (slug === "french") return normalizeFrenchSound(value);
  return normalizeCourseText(slug, value);
}

function japaneseLatinForm(value: string) {
  const source = hasKana(value) ? kanaToRomaji(value) : value;
  return normalizeJapaneseLatin(source);
}

function japaneseSoundForm(value: string) {
  return normalizeJapanesePhonetics(japaneseLatinForm(value));
}

function normalizeJapaneseLatin(value: string) {
  return normalizeAscii(value)
    .replace(/ou/g, "o")
    .replace(/oo/g, "o")
    .replace(/uu/g, "u")
    .replace(/aa/g, "a")
    .replace(/ee/g, "e")
    .replace(/ei/g, "e")
    .replace(/wo/g, "o")
    .replace(/fu/g, "hu")
    .replace(/tsu/g, "tu")
    .replace(/shi/g, "si")
    .replace(/chi/g, "ti")
    .replace(/ji/g, "zi");
}

function normalizeJapanesePhonetics(value: string) {
  return JAPANESE_SOUND_REPLACEMENTS.reduce(
    (current, [pattern, next]) => current.replace(pattern, next),
    normalizeJapaneseLatin(value)
      .replace(/ee/g, "i")
      .replace(/oo/g, "u"),
  );
}

function normalizeGermanText(value: string) {
  return normalizeAscii(value)
    .replace(/ä/g, "ae")
    .replace(/ö/g, "oe")
    .replace(/ü/g, "ue")
    .replace(/ß/g, "ss");
}

function normalizeGermanSound(value: string) {
  return normalizeGermanText(value)
    .replace(/sch/g, "sh")
    .replace(/sp/g, "shp")
    .replace(/st/g, "sht")
    .replace(/z/g, "ts")
    .replace(/w/g, "v");
}

function normalizeSpanishSound(value: string) {
  return normalizeAscii(value)
    .replace(/ll/g, "y")
    .replace(/qu/g, "k")
    .replace(/gue/g, "ge")
    .replace(/gui/g, "gi")
    .replace(/ce/g, "se")
    .replace(/ci/g, "si")
    .replace(/z/g, "s")
    .replace(/v/g, "b")
    .replace(/h/g, "");
}

function normalizeFrenchSound(value: string) {
  return normalizeAscii(value)
    .replace(/eau/g, "o")
    .replace(/au/g, "o")
    .replace(/ou/g, "u")
    .replace(/oi/g, "wa")
    .replace(/ch/g, "sh")
    .replace(/gn/g, "ny")
    .replace(/[sxdtp]$/g, "")
    .replace(/ent$/g, "an");
}

function normalizeEnglishSound(value: string) {
  return normalizeAscii(value)
    .replace(/'re/g, " are")
    .replace(/'ve/g, " have")
    .replace(/'ll/g, " will")
    .replace(/n't/g, " not");
}

function normalizeWhitespace(value: string) {
  return value.replace(/\s+/g, " ").trim();
}

function normalizeAscii(value: string) {
  return value
    .normalize("NFKD")
    .replace(/\p{M}/gu, "")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s-]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function compactLatin(value: string) {
  return value.replace(/[^a-z0-9]/g, "");
}

function compactKana(value: string) {
  return toHiragana(value).replace(/[^\p{Script=Hiragana}\p{Script=Han}\p{N}]/gu, "");
}

function toHiragana(value: string) {
  return Array.from(value).map((char) => {
    const code = char.charCodeAt(0);
    if (code >= 0x30a1 && code <= 0x30f6) {
      return String.fromCharCode(code - 0x60);
    }
    return char;
  }).join("");
}

function hasKana(value: string) {
  return /[\u3040-\u30ff]/.test(value);
}

function phraseSimilarity(source: string, target: string) {
  if (!source || !target) return 0;
  if (source === target) return 1;
  if (source.includes(target) || target.includes(source)) return 0.9;
  return Number(
    ((levenshteinRatio(source, target) * 0.6) + (bigramScore(source, target) * 0.4)).toFixed(2),
  );
}

function levenshteinRatio(source: string, target: string) {
  const rows = Array.from({ length: source.length + 1 }, (_, index) => index);

  for (let column = 1; column <= target.length; column += 1) {
    let diagonal = rows[0];
    rows[0] = column;

    for (let row = 1; row <= source.length; row += 1) {
      const nextDiagonal = rows[row];
      const cost = source[row - 1] === target[column - 1] ? 0 : 1;
      rows[row] = Math.min(rows[row] + 1, rows[row - 1] + 1, diagonal + cost);
      diagonal = nextDiagonal;
    }
  }

  const distance = rows[source.length];
  return 1 - distance / Math.max(source.length, target.length, 1);
}

function bigramScore(source: string, target: string) {
  const left = toBigrams(source);
  const right = toBigrams(target);
  if (!left.length || !right.length) return 0;

  const rightSet = new Set(right);
  const matches = left.filter((value) => rightSet.has(value)).length;
  return (2 * matches) / (left.length + right.length);
}

function toBigrams(value: string) {
  if (value.length < 2) return [value];
  return Array.from({ length: value.length - 1 }, (_, index) =>
    value.slice(index, index + 2),
  );
}

function uniqueStrings(values: string[]) {
  return Array.from(new Set(values.filter(Boolean)));
}
