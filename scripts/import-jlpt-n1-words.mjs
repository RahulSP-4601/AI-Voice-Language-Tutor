import { readFile } from "node:fs/promises";
import path from "node:path";
import { buildJlptN1CourseStructure } from "./jlpt-n1-course-structure.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";
import { deleteRows, upsertRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n1-words.json");
const VOCAB_SORT_OFFSET = 4000;

loadLocalEnv();

function slugify(value) {
  return value
    .toLowerCase()
    .replaceAll(/[^a-z0-9]+/g, "-")
    .replaceAll(/^-+|-+$/g, "");
}

function buildHeaders() {
  const baseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!baseUrl || !serviceRoleKey) {
    throw new Error("Missing Supabase environment variables for N1 import.");
  }
  return {
    baseUrl,
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
    },
  };
}

async function fetchExistingJapaneseVocab() {
  const { baseUrl, headers } = buildHeaders();
  const rows = [];
  const pageSize = 1000;

  for (let start = 0; ; start += pageSize) {
    const url = new URL("/rest/v1/curriculum_vocab_entries", baseUrl);
    url.searchParams.set("select", "japanese,romaji,category_id");
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
      return rows.filter((row) => !String(row.category_id || "").startsWith("n1-"));
    }
  }
}

function normalizeKey(value) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, "")
    .replace(/\s+/g, " ")
    .trim();
}

function buildExistingKey(entry) {
  return `${normalizeKey(entry.japanese)}::${normalizeKey(entry.romaji)}`;
}

function buildCategoryRows(words) {
  const seen = new Map();

  words.forEach((word) => {
    const title = word.wordType || "unknown";
    if (!seen.has(title)) {
      seen.set(title, {
        id: `n1-${slugify(title)}`,
        language_slug: "japanese",
        sort_order: seen.size + 1,
        title,
      });
    }
  });

  return Array.from(seen.values());
}

function buildEntryRows(words, categories) {
  const categoryByTitle = new Map(categories.map((row) => [row.title, row.id]));

  return words.map((word, index) => ({
    id: `n1-word-${String(index + 1).padStart(4, "0")}`,
    category_id: categoryByTitle.get(word.wordType || "unknown") ?? "n1-unknown",
    language_slug: "japanese",
    japanese: word.japanese,
    romaji: word.reading,
    phonetic_hint: word.phoneticHint || generatePronunciationHint(word.reading || word.japanese),
    english: word.english,
    example: word.example || `${word.japanese} means ${word.english}.`,
    sort_order: VOCAB_SORT_OFFSET + index + 1,
  }));
}

function buildLanguageRow() {
  return {
    slug: "japanese",
    name: "Japanese",
    framework_name: "JLPT",
    native_support_label: "English support stays available while the learner speaks each word aloud.",
    hero_summary: "Learn Japanese through JLPT-aligned speaking lessons that turn advanced vocabulary into steady listening, meaning, and pronunciation progress.",
    lesson_duration: "15-20 minute voice lesson",
  };
}

function buildLevelRow(lessonCount, importedCount, skippedCount) {
  return {
    id: "jp-n1",
    language_slug: "japanese",
    official_label: "N1",
    product_label: "Basic 5",
    objective: `Complete the JLPT N1 journey by moving lesson by lesson through the ${importedCount}-word bank with listening, meaning, and speaking practice.`,
    exam_title: "JLPT N1 certificate exam",
    pass_requirement: `Finish all ${lessonCount} lessons and complete the final N1 certificate check.`,
    certificate_title: "JLPT N1 completion certificate",
    certificate_summary: `Issued after the learner completes all ${lessonCount} N1 lessons and clears the certificate checkpoint. ${skippedCount} duplicate words were skipped because they already existed in Japanese vocab.`,
    sort_order: 4,
  };
}

async function readPayload() {
  const raw = await readFile(INPUT_FILE, "utf8");
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.words) || parsed.words.length === 0) {
    throw new Error("Expected data/jlpt-n1-words.json to contain extracted N1 vocabulary words.");
  }

  return parsed;
}

function filterNewWords(words, existingEntries) {
  const existingKeys = new Set(existingEntries.map(buildExistingKey));
  const filtered = [];
  const skipped = [];

  for (const word of words) {
    const key = `${normalizeKey(word.japanese)}::${normalizeKey(word.reading)}`;
    if (existingKeys.has(key)) {
      skipped.push(word);
      continue;
    }
    existingKeys.add(key)
    filtered.push(word);
  }

  return { filtered, skipped };
}

async function upsertRowChunks(table, rows, conflictColumn = "id") {
  const chunkSize = 200;

  for (let index = 0; index < rows.length; index += chunkSize) {
    await upsertRows(table, rows.slice(index, index + chunkSize), conflictColumn);
  }
}

async function main() {
  const payload = await readPayload();
  const existingEntries = await fetchExistingJapaneseVocab();
  const { filtered: words, skipped } = filterNewWords(payload.words, existingEntries);

  if (words.length === 0) {
    throw new Error("All extracted N1 words already exist in the database. Nothing new to import.");
  }

  const categories = buildCategoryRows(words);
  const entries = buildEntryRows(words, categories);
  const structure = buildJlptN1CourseStructure(words);

  await deleteRows("curriculum_vocab_entries", "category_id", "n1-vocabulary");
  await deleteRows("curriculum_vocab_categories", "id", "n1-vocabulary");
  await deleteRows("curriculum_lessons", "level_id", "jp-n1");
  await deleteRows("curriculum_modules", "level_id", "jp-n1");
  await deleteRows("curriculum_modules", "id", "jp-n1-roadmap");

  await upsertRows("curriculum_languages", [buildLanguageRow()], "slug");
  await upsertRows("curriculum_levels", [buildLevelRow(structure.modules.length, words.length, skipped.length)]);
  await upsertRowChunks("curriculum_modules", structure.modules);
  await upsertRowChunks("curriculum_lessons", structure.lessons);
  await upsertRowChunks("curriculum_vocab_categories", categories);
  await upsertRowChunks("curriculum_vocab_entries", entries);

  console.log(`Upserted ${structure.modules.length} N1 lesson modules.`);
  console.log(`Upserted ${structure.lessons.length} N1 lesson rows.`);
  console.log(`Inserted ${categories.length} N1 vocab categories.`);
  console.log(`Inserted ${entries.length} N1 vocab entries from ${INPUT_FILE}.`);
  console.log(`Skipped ${skipped.length} N1 words because they already existed in Japanese vocab.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
