import { readFile } from "node:fs/promises";
import path from "node:path";

const ALL_DATA_FILES = [
  "data/jlpt-n5-words.json",
  "data/jlpt-n4-words.json",
  "data/jlpt-n3-words.json",
  "data/jlpt-n2-words.json",
  "data/jlpt-n1-words.json",
];
const DEFAULT_DATA_FILES = ["data/jlpt-n5-words.json"];

const JAPANESE_NUMBER_OVERRIDES = new Map([
  ["九", "きゅう"],
  ["七", "なな"],
  ["四", "よん"],
  ["何", "なに"],
]);

function hasJapaneseCharacters(value) {
  return /[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff々]/u.test(value);
}

function hasKanaSoundCharacters(value) {
  return /[\u3040-\u30ffー]/u.test(value);
}

function hasKanji(value) {
  return /[\u3400-\u4dbf\u4e00-\u9fff々]/u.test(value);
}

function normalizeReadingValue(value) {
  return String(value ?? "").replace(/\s+/g, " ").trim();
}

function normalizeJapaneseSpeechSource(value) {
  return normalizeReadingValue(value)
    .replace(/[（(][^）)]{1,4}[）)]/g, "")
    .replace(/[・]/g, "")
    .replace(/[…。｡]+/g, "")
    .trim();
}

function deriveReadingFromJapanese(value) {
  const normalized = normalizeJapaneseSpeechSource(value);
  if (!normalized || hasKanji(normalized)) {
    return "";
  }

  return hasKanaSoundCharacters(normalized) ? normalized : "";
}

function splitReadingVariants(value) {
  return normalizeReadingValue(value)
    .split("/")
    .map((part) => part.trim())
    .filter(Boolean);
}

function resolvePreferredReading(word) {
  const explicitOverride = JAPANESE_NUMBER_OVERRIDES.get(word.japanese);
  if (explicitOverride) {
    return explicitOverride;
  }

  const variants = splitReadingVariants(word.reading);
  if (!variants.length) {
    return deriveReadingFromJapanese(word.japanese);
  }

  const japaneseVariant = variants.find(hasJapaneseCharacters);
  if (japaneseVariant) {
    return normalizeReadingValue(japaneseVariant);
  }

  const derivedReading = deriveReadingFromJapanese(word.japanese);
  if (derivedReading) {
    return derivedReading;
  }

  return normalizeReadingValue(variants[0]);
}

function resolveSpeechText(word) {
  const preferredReading = resolvePreferredReading(word);
  if (hasJapaneseCharacters(preferredReading)) {
    return preferredReading;
  }

  return normalizeReadingValue(word.japanese);
}

function resolveSpeechFallback(word) {
  const preferredReading = resolvePreferredReading(word);
  const rawReading = normalizeReadingValue(word.reading);
  if (rawReading && rawReading !== preferredReading) {
    return rawReading;
  }

  return preferredReading ? `${preferredReading}。` : rawReading;
}

function createWordRef(filePath, index, word) {
  return `${filePath}#${index + 1} ${word.japanese} (${word.reading || "no-reading"})`;
}

function detectIssueType(issue) {
  if (issue.includes("missing japanese or reading")) return "missing_reading";
  if (issue.includes("speech text falls back to written kanji")) return "kanji_fallback";
  if (issue.includes("preferred reading is not in kana")) return "non_kana_reading";
  if (issue.includes("ambiguous multi-reading word has no preferred reading")) {
    return "ambiguous_reading";
  }
  if (issue.includes("empty speech text")) return "empty_speech_text";
  if (issue.includes("empty fallback speech text")) return "empty_fallback_text";
  return "other";
}

function summarizeIssues(issues) {
  const byFile = new Map();

  for (const issue of issues) {
    const [ref] = issue.split(": ");
    const filePath = ref.split("#")[0];
    const issueType = detectIssueType(issue);
    const fileSummary = byFile.get(filePath) ?? {
      total: 0,
      types: new Map(),
    };

    fileSummary.total += 1;
    fileSummary.types.set(issueType, (fileSummary.types.get(issueType) ?? 0) + 1);
    byFile.set(filePath, fileSummary);
  }

  return byFile;
}

function formatIssueType(type) {
  if (type === "missing_reading") return "missing reading";
  if (type === "kanji_fallback") return "kanji fallback";
  if (type === "non_kana_reading") return "non-kana reading";
  if (type === "ambiguous_reading") return "ambiguous reading";
  if (type === "empty_speech_text") return "empty speech text";
  if (type === "empty_fallback_text") return "empty fallback text";
  return type.replaceAll("_", " ");
}

function collectIssues(filePath, words) {
  const issues = [];

  words.forEach((word, index) => {
    const preferredReading = resolvePreferredReading(word);
    const speechText = resolveSpeechText(word);
    const fallback = resolveSpeechFallback(word);
    const ref = createWordRef(filePath, index, word);

    if (!word.japanese || !resolvePreferredReading(word)) {
      issues.push(`${ref}: missing japanese or reading.`);
      return;
    }

    if (!speechText) {
      issues.push(`${ref}: empty speech text.`);
    }

    if (!fallback) {
      issues.push(`${ref}: empty fallback speech text.`);
    }

    if (hasKanji(word.japanese) && speechText === word.japanese) {
      issues.push(`${ref}: speech text falls back to written kanji.`);
    }

    if (hasKanji(word.japanese) && !hasJapaneseCharacters(preferredReading)) {
      issues.push(`${ref}: preferred reading is not in kana.`);
    }

    if (splitReadingVariants(word.reading).length > 1 && !preferredReading) {
      issues.push(`${ref}: ambiguous multi-reading word has no preferred reading.`);
    }
  });

  return issues;
}

async function readWords(filePath) {
  const absolutePath = path.resolve(process.cwd(), filePath);
  const raw = await readFile(absolutePath, "utf8");
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.words)) {
    throw new Error(`${filePath} does not contain a words array.`);
  }

  return parsed.words;
}

async function main() {
  const includeAll = process.argv.includes("--all");
  const dataFiles = includeAll ? ALL_DATA_FILES : DEFAULT_DATA_FILES;
  const allIssues = [];
  let totalWords = 0;

  for (const filePath of dataFiles) {
    const words = await readWords(filePath);
    totalWords += words.length;
    allIssues.push(...collectIssues(filePath, words));
  }

  if (allIssues.length > 0) {
    console.error("Practice speech verification failed:");
    const summary = summarizeIssues(allIssues);
    for (const [filePath, fileSummary] of summary.entries()) {
      const details = Array.from(fileSummary.types.entries())
        .sort((left, right) => right[1] - left[1])
        .map(([type, count]) => `${count} ${formatIssueType(type)}`)
        .join(", ");
      console.error(`- ${filePath}: ${fileSummary.total} issues (${details})`);
    }
    console.error("- Example rows:");
    for (const issue of allIssues.slice(0, 100)) {
      console.error(`- ${issue}`);
    }
    if (allIssues.length > 100) {
      console.error(`- ...and ${allIssues.length - 100} more issues`);
    }
    process.exit(1);
  }

  console.log(`Practice speech verification passed for ${totalWords} words.`);
  console.log(
    includeAll
      ? "Verified the full imported bank."
      : "Verified the active N5 practice bank. Use --all to scan every imported bank.",
  );
  console.log("This check is internal only and does not run for end users.");
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
