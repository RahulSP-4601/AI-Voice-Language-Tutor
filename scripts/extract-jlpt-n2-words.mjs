import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";

const OUTPUT_DIR = path.resolve(process.cwd(), "data");
const OUTPUT_FILE = path.join(OUTPUT_DIR, "jlpt-n2-words.json");
const VOCAB_FILE = path.join(OUTPUT_DIR, "JLPT N2 VOCABULARY.pdf");
const KANJI_FILE = path.join(OUTPUT_DIR, "JLPT N2 KANJI LIST.pdf");

function normalizeWhitespace(value) {
  return value.replace(/\s+/g, " ").trim();
}

function runPdfExtractor() {
  const scriptPath = path.resolve(process.cwd(), "scripts", "extract-jlpt-n2-pdfs.py");
  const result = spawnSync("python3", [scriptPath, VOCAB_FILE, KANJI_FILE], {
    cwd: process.cwd(),
    encoding: "utf8",
  });

  if (result.status !== 0) {
    throw new Error(result.stderr.trim() || "Failed extracting N2 data from the PDF files.");
  }

  return JSON.parse(result.stdout);
}

function buildWordRows(rows, source) {
  return rows.map((row, index) => ({
    id: index + 1,
    japanese: normalizeWhitespace(row.japanese),
    reading: normalizeWhitespace(row.reading),
    phoneticHint: generatePronunciationHint(normalizeWhitespace(row.reading)),
    english: normalizeWhitespace(row.english || ""),
    wordType: "vocabulary",
    verbType: "",
    masuForm: "",
    teForm: "",
    example: "",
    sortOrder: index + 1,
    source,
    sourceNumber: Number(row.sourceNumber ?? index + 1),
    sourceNumbers: Array.isArray(row.sourceNumbers) ? row.sourceNumbers : [Number(row.sourceNumber ?? index + 1)],
  }));
}

function buildKanjiRows(rows, source) {
  return rows.map((row, index) => ({
    id: index + 1,
    japanese: normalizeWhitespace(row.japanese),
    reading: normalizeWhitespace(row.reading),
    phoneticHint: generatePronunciationHint(normalizeWhitespace(row.reading)),
    meaning: normalizeWhitespace(row.english || ""),
    example: "",
    sortOrder: index + 1,
    source,
    sourceNumber: Number(row.sourceNumber ?? index + 1),
    sourceNumbers: Array.isArray(row.sourceNumbers) ? row.sourceNumbers : [Number(row.sourceNumber ?? index + 1)],
  }));
}

async function main() {
  const payload = runPdfExtractor();
  const vocabulary = payload.vocabulary ?? {};
  const kanji = payload.kanji ?? {};
  const words = buildWordRows(vocabulary.rows ?? [], "migii-n2-vocabulary-pdf");
  const kanjiRows = buildKanjiRows(kanji.rows ?? [], "migii-n2-kanji-pdf");

  await mkdir(OUTPUT_DIR, { recursive: true });
  await writeFile(
    OUTPUT_FILE,
    `${JSON.stringify(
      {
        extractedAt: new Date().toISOString(),
        sources: {
          kanji: {
            file: KANJI_FILE,
            highestSourceNumber: Number(kanji.highestSourceNumber ?? kanjiRows.length),
            missingSourceNumbers: Array.isArray(kanji.missingSourceNumbers) ? kanji.missingSourceNumbers : [],
            rawRowCount: Number(kanji.rawRowCount ?? kanjiRows.length),
            source: "Migii JLPT N2 KANJI LIST PDF",
            uniqueRowCount: Number(kanji.uniqueRowCount ?? kanjiRows.length),
          },
          vocabulary: {
            file: VOCAB_FILE,
            highestSourceNumber: Number(vocabulary.highestSourceNumber ?? words.length),
            missingSourceNumbers: Array.isArray(vocabulary.missingSourceNumbers) ? vocabulary.missingSourceNumbers : [],
            rawRowCount: Number(vocabulary.rawRowCount ?? words.length),
            source: "Migii JLPT N2 VOCABULARY PDF",
            uniqueRowCount: Number(vocabulary.uniqueRowCount ?? words.length),
          },
        },
        counts: {
          kanji: kanjiRows.length,
          words: words.length,
        },
        words,
        kanji: kanjiRows,
      },
      null,
      2,
    )}\n`,
    "utf8",
  );

  console.log(`Saved ${words.length} N2 words and ${kanjiRows.length} kanji entries to ${OUTPUT_FILE}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
