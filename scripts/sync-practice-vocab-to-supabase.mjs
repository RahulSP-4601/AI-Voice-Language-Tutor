import { readFile } from "node:fs/promises";
import path from "node:path";
import { loadLocalEnv } from "./load-local-env.mjs";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";
import { upsertRows } from "./supabase-admin-rest.mjs";

loadLocalEnv();

const LEVELS = [
  { file: "data/jlpt-n5-words.json", idPrefix: "n5-word-", level: "n5" },
  { file: "data/jlpt-n4-words.json", idPrefix: "n4-word-", level: "n4" },
  { file: "data/jlpt-n3-words.json", idPrefix: "n3-word-", level: "n3" },
  { file: "data/jlpt-n2-words.json", idPrefix: "n2-word-", level: "n2" },
  { file: "data/jlpt-n1-words.json", idPrefix: "n1-word-", level: "n1" },
];

function normalize(value) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, "")
    .replace(/\s+/g, " ")
    .trim();
}

function buildEntryId(level, index) {
  return `${level}-word-${String(index + 1).padStart(4, "0")}`;
}

function buildMatchKey(word) {
  return `${normalize(word.japanese)}::${normalize(word.english)}`;
}

async function fetchExistingJapaneseVocab() {
  const baseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!baseUrl || !serviceRoleKey) {
    throw new Error("Missing Supabase environment variables for vocab sync.");
  }

  const headers = {
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
  };

  const rows = [];
  const pageSize = 1000;

  for (let start = 0; ; start += pageSize) {
    const url = new URL("/rest/v1/curriculum_vocab_entries", baseUrl);
    url.searchParams.set(
      "select",
      "id,category_id,language_slug,japanese,romaji,phonetic_hint,english,example,sort_order",
    );
    url.searchParams.set("language_slug", "eq.japanese");
    url.searchParams.set("order", "sort_order.asc");

    const response = await fetch(url, {
      headers: {
        ...headers,
        Range: `${start}-${start + pageSize - 1}`,
      },
    });

    const text = await response.text();
    if (!response.ok) {
      throw new Error(`Failed reading existing Japanese vocab rows: ${text}`);
    }

    const batch = text ? JSON.parse(text) : [];
    rows.push(...batch);

    if (batch.length < pageSize) {
      return rows;
    }
  }
}

async function readWords(filePath) {
  const raw = await readFile(path.resolve(process.cwd(), filePath), "utf8");
  const parsed = JSON.parse(raw);
  if (!Array.isArray(parsed.words)) {
    throw new Error(`${filePath} does not contain a words array.`);
  }
  return parsed.words;
}

function buildUpdatedRow(existingRow, word) {
  return {
    id: existingRow.id,
    category_id: existingRow.category_id,
    language_slug: existingRow.language_slug || "japanese",
    japanese: existingRow.japanese || word.japanese,
    romaji: word.reading,
    phonetic_hint: generatePronunciationHint(word.reading || word.japanese),
    english: existingRow.english || word.english,
    example: existingRow.example || word.example || `${word.japanese} means ${word.english}.`,
    sort_order: existingRow.sort_order,
  };
}

function collectDeterministicUpdates(level, words, existingById) {
  const updates = [];
  const missing = [];

  words.forEach((word, index) => {
    const id = buildEntryId(level.level, index);
    const existingRow = existingById.get(id);
    if (!existingRow) {
      missing.push(`${id} (${word.japanese})`);
      return;
    }

    updates.push(buildUpdatedRow(existingRow, word));
  });

  return { missing, updates };
}

function findSharedFallbackMatch(word, fallbackRows) {
  const exactMatches = fallbackRows.filter(
    (row) => buildMatchKey(row) === buildMatchKey(word),
  );
  if (exactMatches.length >= 1) {
    return exactMatches[0];
  }

  const japaneseMatches = fallbackRows.filter(
    (row) => normalize(row.japanese) === normalize(word.japanese),
  );
  if (japaneseMatches.length === 1) {
    return japaneseMatches[0];
  }

  return null;
}

function collectN1Updates(words, existingRows, fallbackRows) {
  const updates = [];
  const missing = [];
  const matchedIds = new Set();

  for (const word of words) {
    const exactMatches = existingRows.filter(
      (row) => !matchedIds.has(row.id) && buildMatchKey(row) === buildMatchKey(word),
    );
    let existingRow = exactMatches[0] ?? null;

    if (!existingRow) {
      const japaneseMatches = existingRows.filter(
        (row) => !matchedIds.has(row.id) && normalize(row.japanese) === normalize(word.japanese),
      );
      if (japaneseMatches.length === 1) {
        existingRow = japaneseMatches[0];
      }
    }

    if (!existingRow) {
      existingRow = findSharedFallbackMatch(word, fallbackRows);
    }

    if (!existingRow) {
      missing.push(`${word.japanese} (${word.reading || "no-reading"})`);
      continue;
    }

    if (String(existingRow.category_id || "").startsWith("n1-")) {
      matchedIds.add(existingRow.id);
    }
    updates.push(buildUpdatedRow(existingRow, word));
  }

  return { missing, updates };
}

async function upsertRowChunks(table, rows, conflictColumn = "id") {
  const chunkSize = 200;
  for (let index = 0; index < rows.length; index += chunkSize) {
    await upsertRows(table, rows.slice(index, index + chunkSize), conflictColumn);
  }
}

async function buildSyncPlan() {
  const existingRows = await fetchExistingJapaneseVocab();
  const existingById = new Map(existingRows.map((row) => [row.id, row]));
  const existingN1Rows = existingRows.filter((row) =>
    String(row.category_id || "").startsWith("n1-"),
  );
  const existingNonN1Rows = existingRows.filter(
    (row) => !String(row.category_id || "").startsWith("n1-"),
  );
  const allUpdates = [];
  const summary = [];

  for (const level of LEVELS) {
    const words = await readWords(level.file);
    const result =
      level.level === "n1"
        ? collectN1Updates(words, existingN1Rows, existingNonN1Rows)
        : collectDeterministicUpdates(level, words, existingById);

    allUpdates.push(...result.updates);
    summary.push({
      level: level.level.toUpperCase(),
      matched: result.updates.length,
      missing: result.missing,
      total: words.length,
    });
  }

  return {
    dedupedUpdates: Array.from(new Map(allUpdates.map((row) => [row.id, row])).values()),
    summary,
  };
}

function reportMissingRows(summary) {
  const missingCount = summary.reduce((count, item) => count + item.missing.length, 0);
  if (missingCount === 0) {
    return false;
  }

  console.error("Vocab sync aborted because some existing Supabase rows could not be matched.");
  for (const item of summary) {
    if (!item.missing.length) continue;
    console.error(`- ${item.level}: ${item.missing.length} unmatched rows`);
    for (const missing of item.missing.slice(0, 20)) {
      console.error(`  - ${missing}`);
    }
    if (item.missing.length > 20) {
      console.error(`  - ...and ${item.missing.length - 20} more`);
    }
  }

  return true;
}

function reportSuccess(summary, updatedCount) {
  for (const item of summary) {
    console.log(`Synced ${item.matched}/${item.total} ${item.level} vocab rows.`);
  }
  console.log(`Updated ${updatedCount} curriculum_vocab_entries rows in Supabase.`);
}

async function main() {
  const { dedupedUpdates, summary } = await buildSyncPlan();
  if (reportMissingRows(summary)) {
    process.exit(1);
  }

  await upsertRowChunks("curriculum_vocab_entries", dedupedUpdates);
  reportSuccess(summary, dedupedUpdates.length);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
