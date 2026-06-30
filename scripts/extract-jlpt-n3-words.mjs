import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";

const OUTPUT_DIR = path.resolve(process.cwd(), "data");
const OUTPUT_FILE = path.join(OUTPUT_DIR, "jlpt-n3-words.json");
const PDF_INPUT_FILE = path.join(OUTPUT_DIR, "JLPT N3 VOCABULARY.pdf");

const KANJI_SOURCES = [
  {
    key: "n3-kanji",
    url: "https://jlptsensei.com/jlpt-n3-kanji-list/",
    expectedCount: 100,
    level: "N3",
  },
];

function decodeEntities(value) {
  return value
    .replaceAll("&nbsp;", " ")
    .replaceAll("&amp;", "&")
    .replaceAll("&quot;", "\"")
    .replaceAll("&#039;", "'")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">");
}

function stripTags(value) {
  return decodeEntities(value)
    .replace(/<br\s*\/?>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeWhitespace(value) {
  return value.replace(/\s+/g, " ").trim();
}

function toSentenceCaseList(value) {
  return normalizeWhitespace(
    value
      .replaceAll("、", ", ")
      .replaceAll("，", ", ")
      .replaceAll("；", "; ")
      .replaceAll(/\s*,\s*/g, ", ")
      .replaceAll(/\s*;\s*/g, "; "),
  );
}

async function fetchHtml(url) {
  const response = await fetch(url, {
    headers: {
      "user-agent": "AI-Voice-Tutor research importer",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status}`);
  }

  return response.text();
}

function nextPageUrl(baseUrl, pageNumber) {
  return `${baseUrl.replace(/\/$/, "")}/page/${pageNumber}/`;
}

function parseKanjiRows(html, sourceKey, sourceLevel) {
  const rows = [];
  const rowPattern =
    /<tr class=jl-row><td class="jl-td-num[^"]*">([\s\S]*?)<td class="jl-td-k[^"]*">([\s\S]*?)<td class="jl-td-on[^"]*">([\s\S]*?)<td class="jl-td-kun[^"]*">([\s\S]*?)<td class="jl-td-m[^"]*">([\s\S]*?)(?=<tr(?: class=jl-row)?|<\/table>)/g;

  for (const match of html.matchAll(rowPattern)) {
    const sortOrder = Number.parseInt(stripTags(match[1]), 10);
    const japanese = stripTags(match[2]);
    const onBlock = match[3];
    const kunBlock = match[4];
    const meaning = stripTags(match[5]);

    const reading = toSentenceCaseList(
      [stripTags(onBlock.split("<p")[0] ?? ""), stripTags(kunBlock.split("<p")[0] ?? "")]
        .filter(Boolean)
        .join("; "),
    );
    const phoneticSource = [
      stripTags(onBlock.match(/<p class="mb-0 mt-2">([\s\S]*?)<\/p>/)?.[1] ?? ""),
      stripTags(kunBlock.match(/<p class="mb-0 mt-2">([\s\S]*?)<\/p>/)?.[1] ?? ""),
    ]
      .filter(Boolean)
      .join(" / ");

    if (!japanese || !meaning) {
      continue;
    }

    rows.push({
      id: rows.length + 1,
      japanese,
      meaning,
      reading,
      phoneticHint: generatePronunciationHint(phoneticSource || reading),
      example: "",
      source: sourceKey,
      sourceLevel,
      sortOrder: Number.isFinite(sortOrder) ? sortOrder : rows.length + 1,
    });
  }

  return rows;
}

async function collectPagedRows(source, parser) {
  const rows = [];
  let pageNumber = 1;

  while (rows.length < source.expectedCount) {
    const url = pageNumber === 1 ? source.url : nextPageUrl(source.url, pageNumber);
    const html = await fetchHtml(url);
    const pageRows = parser(html, source.wordType ?? source.key, source.key, source.level);

    if (pageRows.length === 0) {
      break;
    }

    rows.push(...pageRows);

    if (pageRows.length < 100) {
      break;
    }

    pageNumber += 1;
  }

  if (rows.length < source.expectedCount) {
    throw new Error(
      `Expected at least ${source.expectedCount} rows from ${source.url} but extracted ${rows.length}.`,
    );
  }

  return rows.slice(0, source.expectedCount);
}

function extractWordsFromPdf() {
  const scriptPath = path.resolve(process.cwd(), "scripts", "extract-jlpt-n3-vocab-pdf.py");
  const result = spawnSync("python3", [scriptPath, PDF_INPUT_FILE], {
    cwd: process.cwd(),
    encoding: "utf8",
  });

  if (result.status !== 0) {
    throw new Error(result.stderr.trim() || "Failed extracting N3 vocabulary from the PDF.");
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
      phoneticHint: generatePronunciationHint(normalizeWhitespace(row.reading)),
      english: normalizeWhitespace(row.english || ""),
      wordType: "vocabulary",
      verbType: "",
      masuForm: "",
      teForm: "",
      example: "",
      sortOrder: index + 1,
      sourceNumber: Number(row.sourceNumber ?? index + 1),
      sourceNumbers: Array.isArray(row.sourceNumbers) ? row.sourceNumbers : [Number(row.sourceNumber ?? index + 1)],
      source: "migii-pdf",
    })),
  };
}

function dedupeKanji(rows) {
  const seen = new Map();

  rows.forEach((entry) => {
    if (!seen.has(entry.japanese)) {
      seen.set(entry.japanese, {
        ...entry,
        sources: [entry.source],
        sourceLevels: [entry.sourceLevel],
      });
      return;
    }

    const existing = seen.get(entry.japanese);
    if (!existing.meaning.includes(entry.meaning)) {
      existing.meaning = `${existing.meaning}; ${entry.meaning}`;
    }
    if (entry.reading && !existing.reading.includes(entry.reading)) {
      existing.reading = `${existing.reading}; ${entry.reading}`;
    }
    if (!existing.sources.includes(entry.source)) {
      existing.sources.push(entry.source);
    }
    if (!existing.sourceLevels.includes(entry.sourceLevel)) {
      existing.sourceLevels.push(entry.sourceLevel);
    }
  });

  return Array.from(seen.values()).map((entry, index) => ({
    id: index + 1,
    japanese: entry.japanese,
    reading: normalizeWhitespace(entry.reading),
    phoneticHint: entry.phoneticHint || generatePronunciationHint(entry.reading),
    meaning: normalizeWhitespace(entry.meaning),
    example: entry.example,
    sortOrder: index + 1,
    sourceLevels: entry.sourceLevels,
    sources: entry.sources,
  }));
}

async function main() {
  const vocabPayload = extractWordsFromPdf();
  const kanjiBySource = await Promise.all(
    KANJI_SOURCES.map((source) =>
      collectPagedRows(source, (html) =>
        parseKanjiRows(html, source.key, source.level),
      ),
    ),
  );

  const words = vocabPayload.words;
  const kanji = dedupeKanji(kanjiBySource.flat());

  await mkdir(OUTPUT_DIR, { recursive: true });
  await writeFile(
    OUTPUT_FILE,
    `${JSON.stringify(
      {
        extractedAt: new Date().toISOString(),
        sources: {
          kanji: KANJI_SOURCES.map((source) => ({
            expectedCount: source.expectedCount,
            key: source.key,
            level: source.level,
            url: source.url,
          })),
          vocabulary: {
            file: PDF_INPUT_FILE,
            highestSourceNumber: vocabPayload.highestSourceNumber,
            missingSourceNumbers: vocabPayload.missingSourceNumbers,
            rawRowCount: vocabPayload.rawRowCount,
            source: "Migii JLPT N3 VOCABULARY PDF",
            uniqueRowCount: vocabPayload.uniqueRowCount,
          },
        },
        counts: {
          kanji: kanji.length,
          words: words.length,
        },
        words,
        kanji,
      },
      null,
      2,
    )}\n`,
    "utf8",
  );

  console.log(`Saved ${words.length} N3 words and ${kanji.length} kanji to ${OUTPUT_FILE}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
