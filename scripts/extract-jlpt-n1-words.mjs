import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";

const OUTPUT_DIR = path.resolve(process.cwd(), "data");
const OUTPUT_FILE = path.join(OUTPUT_DIR, "jlpt-n1-words.json");
const PDF_INPUT_FILE = path.join(OUTPUT_DIR, "JLPT N1 VOCABULARY.pdf");

function normalizeWhitespace(value) {
  return value.replace(/\s+/g, " ").trim();
}

function extractWordsFromPdf() {
  const scriptPath = path.resolve(process.cwd(), "scripts", "extract-jlpt-n1-vocab-pdf.py");
  const result = spawnSync("python3", [scriptPath, PDF_INPUT_FILE], {
    cwd: process.cwd(),
    encoding: "utf8",
  });

  if (result.status !== 0) {
    throw new Error(result.stderr.trim() || "Failed extracting N1 vocabulary from the PDF.");
  }

  const parsed = JSON.parse(result.stdout);
  const rows = Array.isArray(parsed.rows) ? parsed.rows : [];

  return {
    highestSourceNumber: Number(parsed.highestSourceNumber ?? rows.length),
    rawRowCount: Number(parsed.rawRowCount ?? rows.length),
    uniqueRowCount: Number(parsed.uniqueRowCount ?? rows.length),
    missingSourceNumbers: Array.isArray(parsed.missingSourceNumbers)
      ? parsed.missingSourceNumbers
      : [],
    words: rows.map((row, index) => ({
      id: index + 1,
      japanese: normalizeWhitespace(row.japanese),
      reading: normalizeWhitespace(row.reading),
      phoneticHint: generatePronunciationHint(normalizeWhitespace(row.reading || row.japanese)),
      english: normalizeWhitespace(row.english || ""),
      wordType: "vocabulary",
      verbType: "",
      masuForm: "",
      teForm: "",
      example: "",
      sortOrder: index + 1,
      sourceNumber: Number(row.sourceNumber ?? index + 1),
      sourceNumbers: Array.isArray(row.sourceNumbers)
        ? row.sourceNumbers
        : [Number(row.sourceNumber ?? index + 1)],
      source: "migii-n1-vocabulary-pdf",
    })),
  };
}

async function main() {
  const vocabPayload = extractWordsFromPdf();
  const words = vocabPayload.words;

  await mkdir(OUTPUT_DIR, { recursive: true });
  await writeFile(
    OUTPUT_FILE,
    `${JSON.stringify(
      {
        extractedAt: new Date().toISOString(),
        sources: {
          vocabulary: {
            file: PDF_INPUT_FILE,
            highestSourceNumber: vocabPayload.highestSourceNumber,
            missingSourceNumbers: vocabPayload.missingSourceNumbers,
            rawRowCount: vocabPayload.rawRowCount,
            source: "Migii JLPT N1 VOCABULARY PDF",
            uniqueRowCount: vocabPayload.uniqueRowCount,
          },
        },
        counts: {
          words: words.length,
        },
        words,
      },
      null,
      2,
    )}\n`,
    "utf8",
  );

  console.log(`Saved ${words.length} N1 words to ${OUTPUT_FILE}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
