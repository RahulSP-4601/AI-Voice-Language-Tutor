import { mkdir, writeFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";

const OUTPUT_DIR = path.resolve(process.cwd(), "data");
const OUTPUT_FILE = path.join(OUTPUT_DIR, "jlpt-n1-kanji.json");
const BASE_URL = "https://jlptsensei.com/jlpt-n1-kanji-list/";
const COOKIE_JAR = path.join(os.tmpdir(), "jlpt-n1-kanji-cookies.txt");
const USER_AGENT = "Mozilla/5.0 (compatible; AI-Voice-Tutor/1.0)";
const PAGE_SIZE = 100;
const RETRY_COUNT = 5;
const PAGE_LIMIT = Number(process.env.JLPT_N1_KANJI_PAGE_LIMIT || "0");

function decodeHtml(value) {
  return value
    .replaceAll("&nbsp;", " ")
    .replaceAll("&amp;", "&")
    .replaceAll("&quot;", "\"")
    .replaceAll("&#039;", "'")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replace(/&#(\d+);/g, (_, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCodePoint(parseInt(code, 16)));
}

function stripTags(value) {
  return decodeHtml(value).replace(/<[^>]+>/g, " ");
}

function normalizeText(value) {
  return stripTags(value).replace(/\s+/g, " ").trim();
}

function normalizeReading(value) {
  return normalizeText(value)
    .replaceAll("、", ", ")
    .replaceAll("，", ", ")
    .replaceAll("／", " / ")
    .replace(/\s*\/\s*/g, " / ")
    .replace(/\s*,\s*/g, ", ");
}

function buildPageUrl(pageNumber) {
  return pageNumber === 1 ? BASE_URL : `${BASE_URL}page/${pageNumber}/`;
}

async function fetchHtml(pageNumber) {
  const result = spawnSync("curl", [
    "-L",
    "--compressed",
    "-b",
    COOKIE_JAR,
    "-c",
    COOKIE_JAR,
    "-A",
    USER_AGENT,
    "-H",
    "Accept-Language: en-US,en;q=0.9",
    "-e",
    BASE_URL,
    buildPageUrl(pageNumber),
  ], {
    cwd: process.cwd(),
    encoding: "utf8",
  });

  if (result.status !== 0) {
    throw new Error(result.stderr.trim() || `Failed fetching N1 kanji page ${pageNumber}.`);
  }

  return result.stdout;
}

function extractTotalPages(html) {
  const match = html.match(/Currently viewing page\s+1\s+of\s+(\d+)/i);
  if (!match) {
    throw new Error("Could not determine total N1 kanji pages from page 1.");
  }
  return Number(match[1]);
}

function extractTotalRows(html) {
  const match = html.match(/JLPT N1 Kanji List total:\s*\((\d+)\)/i);
  if (!match) {
    throw new Error("Could not determine total N1 kanji rows from page 1.");
  }
  return Number(match[1]);
}

function matchCell(rowHtml, currentClass, nextClass) {
  const pattern = new RegExp(
    `<td class="[^"]*${currentClass}[^"]*"[^>]*>([\\s\\S]*?)(?=<td class="[^"]*${nextClass}[^"]*"|$)`,
    "i",
  );
  return rowHtml.match(pattern)?.[1] ?? "";
}

function extractReadingParts(cellHtml) {
  const kanaHtml = cellHtml.match(/<p[^>]*>([\s\S]*?)<\/p>/i)?.[1] ?? "";
  const baseHtml = cellHtml.replace(/<p[^>]*>[\s\S]*?<\/p>/gi, "");
  return {
    kana: normalizeReading(kanaHtml),
    romaji: normalizeReading(baseHtml),
  };
}

function buildCombinedReading(onyomi, kunyomi) {
  return [onyomi.kana, kunyomi.kana].filter(Boolean).join(" / ");
}

function buildExample(onyomi, kunyomi) {
  const parts = [];
  if (onyomi.romaji) parts.push(`On: ${onyomi.romaji}`);
  if (kunyomi.romaji) parts.push(`Kun: ${kunyomi.romaji}`);
  return parts.join(" | ");
}

function parseRow(rowHtml) {
  const number = Number(normalizeText(matchCell(rowHtml, "jl-td-num", "jl-td-k")));
  const japanese = normalizeText(matchCell(rowHtml, "jl-td-k", "jl-td-on"));
  const onyomi = extractReadingParts(matchCell(rowHtml, "jl-td-on", "jl-td-kun"));
  const kunyomi = extractReadingParts(matchCell(rowHtml, "jl-td-kun", "jl-td-m"));
  const meaning = normalizeText(matchCell(rowHtml, "jl-td-m", "jl-td-"));
  const reading = buildCombinedReading(onyomi, kunyomi);

  return {
    id: number,
    japanese,
    reading,
    phoneticHint: generatePronunciationHint(reading),
    meaning,
    example: buildExample(onyomi, kunyomi),
    onyomiKana: onyomi.kana,
    onyomiRomaji: onyomi.romaji,
    kunyomiKana: kunyomi.kana,
    kunyomiRomaji: kunyomi.romaji,
    sortOrder: number,
    source: "jlptsensei-n1-kanji-list",
    sourceNumber: number,
    sourceNumbers: [number],
    sourceUrl: "",
  };
}

function extractRows(html) {
  const rows = html.match(/<tr class=jl-row>[\s\S]*?(?=<tr class=jl-row>|<\/table>)/gi) ?? [];
  return rows.map(parseRow).filter((row) => row.japanese && row.meaning);
}

function mergeRows(existing, incoming) {
  const previous = existing.get(incoming.japanese);
  if (!previous) {
    existing.set(incoming.japanese, incoming);
    return;
  }

  const nextMeaning = previous.meaning.length >= incoming.meaning.length
    ? previous.meaning
    : incoming.meaning;

  existing.set(incoming.japanese, {
    ...previous,
    example: previous.example || incoming.example,
    meaning: nextMeaning,
    reading: previous.reading || incoming.reading,
    phoneticHint: previous.phoneticHint || incoming.phoneticHint,
    sourceNumber: Math.min(previous.sourceNumber, incoming.sourceNumber),
    sourceNumbers: Array.from(new Set([...previous.sourceNumbers, ...incoming.sourceNumbers])).sort((a, b) => a - b),
    sortOrder: Math.min(previous.sortOrder, incoming.sortOrder),
  });
}

function finalizeRows(rowsByKanji) {
  return Array.from(rowsByKanji.values())
    .sort((left, right) => left.sortOrder - right.sortOrder)
    .map((row, index) => ({ ...row, id: index + 1, sortOrder: index + 1 }));
}

function getExpectedPageCount(pageNumber, totalPages, totalRows) {
  if (pageNumber < totalPages) {
    return PAGE_SIZE;
  }
  return totalRows - (PAGE_SIZE * (totalPages - 1));
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchPageRows(pageNumber, totalPages, totalRows) {
  const expectedCount = getExpectedPageCount(pageNumber, totalPages, totalRows);

  for (let attempt = 1; attempt <= RETRY_COUNT; attempt += 1) {
    const html = await fetchHtml(pageNumber);
    const rows = extractRows(html);
    if (rows.length === expectedCount) {
      return rows;
    }
    await wait(250 * attempt);
  }

  throw new Error(`Page ${pageNumber} did not return the expected ${expectedCount} kanji rows.`);
}

async function collectRows() {
  const firstPageHtml = await fetchHtml(1);
  const totalPages = extractTotalPages(firstPageHtml);
  const totalRows = extractTotalRows(firstPageHtml);
  const pageCount = PAGE_LIMIT > 0 ? Math.min(PAGE_LIMIT, totalPages) : totalPages;
  let rawRowCount = 0;
  const rowsByKanji = new Map();

  const firstPageRows = extractRows(firstPageHtml);
  if (firstPageRows.length !== PAGE_SIZE) {
    throw new Error("Page 1 did not return the expected 100 kanji rows.");
  }
  rawRowCount += firstPageRows.length;
  firstPageRows.forEach((row) => mergeRows(rowsByKanji, row));

  for (let page = 2; page <= pageCount; page += 1) {
    const pageRows = await fetchPageRows(page, totalPages, totalRows);
    rawRowCount += pageRows.length;
    pageRows.forEach((row) => mergeRows(rowsByKanji, row));
  }

  return {
    pageCount,
    rawRowCount,
    rows: finalizeRows(rowsByKanji),
    totalPages,
    totalRows,
  };
}

async function main() {
  const { rows, totalPages, totalRows, rawRowCount, pageCount } = await collectRows();

  await mkdir(OUTPUT_DIR, { recursive: true });
  await writeFile(
    OUTPUT_FILE,
    `${JSON.stringify(
      {
        extractedAt: new Date().toISOString(),
        sources: {
          kanji: {
            source: "JLPT Sensei JLPT N1 Kanji List",
            fetchedPages: pageCount,
            totalPages,
            totalRows,
            url: BASE_URL,
            rawRowCount,
            duplicateRowCount: rawRowCount - rows.length,
            uniqueRowCount: rows.length,
          },
        },
        counts: {
          kanji: rows.length,
        },
        kanji: rows,
      },
      null,
      2,
    )}\n`,
    "utf8",
  );

  console.log(`Saved ${rows.length} N1 kanji entries to ${OUTPUT_FILE}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
