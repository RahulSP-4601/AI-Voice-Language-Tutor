import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";

const N4_WORDS_URL = "https://jlptvocab.com/level/n4/words";
const OUTPUT_DIR = path.resolve(process.cwd(), "data");
const OUTPUT_FILE = path.join(OUTPUT_DIR, "jlpt-n4-words.json");
const EXPECTED_WORD_COUNT = 800;

function readWordPayloadToken(html) {
  const tokens = ["\\\"words\\\":[", "\"words\":["];

  for (const token of tokens) {
    const start = html.indexOf(token);
    if (start !== -1) {
      return start + token.length - 1;
    }
  }

  throw new Error("Unable to find the words payload on the N4 words page.");
}

function readJsonArrayChunk(source, startIndex) {
  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let index = startIndex; index < source.length; index += 1) {
    const char = source[index];

    if (escaped) {
      escaped = false;
      continue;
    }

    if (char === "\\") {
      escaped = true;
      continue;
    }

    if (char === "\"") {
      inString = !inString;
      continue;
    }

    if (inString) {
      continue;
    }

    if (char === "[") {
      depth += 1;
    }

    if (char === "]") {
      depth -= 1;
      if (depth === 0) {
        return source.slice(startIndex, index + 1);
      }
    }
  }

  throw new Error("Unable to extract the full words array from the page.");
}

function cleanStringValue(value) {
  if (typeof value !== "string") {
    return "";
  }

  return value.replaceAll("$undefined", "").trim();
}

function toExampleText(exampleSentences) {
  if (!Array.isArray(exampleSentences)) {
    return "";
  }

  return exampleSentences
    .map((sentence) => {
      const japanese = cleanStringValue(sentence?.japanese);
      const english = cleanStringValue(sentence?.english);
      if (!japanese && !english) {
        return "";
      }
      return `${japanese} :: ${english}`.trim();
    })
    .filter(Boolean)
    .join(" || ");
}

function normalizeWord(word, index) {
  return {
    id: Number(word.id ?? index + 1),
    japanese: cleanStringValue(word.japanese),
    reading: cleanStringValue(word.reading),
    phoneticHint: generatePronunciationHint(cleanStringValue(word.reading)),
    english: cleanStringValue(word.english),
    wordType: cleanStringValue(word.wordType) || "unknown",
    verbType: cleanStringValue(word.verbType),
    masuForm: cleanStringValue(word.masuForm),
    teForm: cleanStringValue(word.teForm),
    example: toExampleText(word.exampleSentences),
    sortOrder: index + 1,
  };
}

function parseWordsPayload(wordsJson) {
  try {
    return JSON.parse(wordsJson);
  } catch {
    return JSON.parse(wordsJson.replaceAll("\\\"", "\""));
  }
}

async function fetchHtml() {
  const response = await fetch(N4_WORDS_URL, {
    headers: {
      "user-agent": "AI-Voice-Tutor research importer",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch N4 words page: ${response.status}`);
  }

  return response.text();
}

async function main() {
  const html = await fetchHtml();
  const payloadStart = readWordPayloadToken(html);
  const wordsJson = readJsonArrayChunk(html, payloadStart);
  const rawWords = parseWordsPayload(wordsJson);
  const words = rawWords.map(normalizeWord);

  if (words.length !== EXPECTED_WORD_COUNT) {
    throw new Error(`Expected ${EXPECTED_WORD_COUNT} N4 words but extracted ${words.length}.`);
  }

  await mkdir(OUTPUT_DIR, { recursive: true });
  await writeFile(
    OUTPUT_FILE,
    `${JSON.stringify({ extractedAt: new Date().toISOString(), source: N4_WORDS_URL, words }, null, 2)}\n`,
    "utf8",
  );

  console.log(`Saved ${words.length} N4 words to ${OUTPUT_FILE}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
