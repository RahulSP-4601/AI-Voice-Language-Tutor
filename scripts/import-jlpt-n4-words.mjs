import { readFile } from "node:fs/promises";
import path from "node:path";
import { buildJlptN4CourseStructure } from "./jlpt-n4-course-structure.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";
import { upsertRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n4-words.json");
const EXPECTED_WORD_COUNT = 800;
const STORED_SORT_OFFSET = 1000;

loadLocalEnv();

function slugify(value) {
  return value
    .toLowerCase()
    .replaceAll(/[^a-z0-9]+/g, "-")
    .replaceAll(/^-+|-+$/g, "");
}

function buildCategoryRows(words) {
  const seen = new Map();

  words.forEach((word) => {
    const title = word.wordType || "unknown";
    if (!seen.has(title)) {
      seen.set(title, {
        id: `n4-${slugify(title)}`,
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
    id: `n4-word-${String(index + 1).padStart(4, "0")}`,
    category_id: categoryByTitle.get(word.wordType || "unknown") ?? "n4-unknown",
    language_slug: "japanese",
    japanese: word.japanese,
    romaji: word.reading,
    phonetic_hint: word.phoneticHint || generatePronunciationHint(word.reading),
    english: word.english,
    example: word.example || `${word.japanese} means ${word.english}.`,
    sort_order: STORED_SORT_OFFSET + index + 1,
  }));
}

function buildLanguageRow() {
  return {
    slug: "japanese",
    name: "Japanese",
    framework_name: "JLPT",
    native_support_label: "English support stays available while the learner speaks each word aloud.",
    hero_summary: "Learn Japanese through JLPT-aligned speaking lessons that turn vocabulary into steady listening, meaning, and pronunciation progress.",
    lesson_duration: "15-20 minute voice lesson",
  };
}

function buildLevelRow() {
  return {
    id: "jp-n4",
    language_slug: "japanese",
    official_label: "N4",
    product_label: "Basic 2",
    objective: "Complete the full JLPT N4 journey by moving lesson by lesson through the 800-word bank with listening, meaning, and speaking practice.",
    exam_title: "JLPT N4 certificate exam",
    pass_requirement: "Finish all 8 lessons and complete the final N4 certificate check.",
    certificate_title: "JLPT N4 completion certificate",
    certificate_summary: "Issued after the learner completes all 8 N4 lessons and clears the certificate checkpoint.",
    sort_order: 1,
  };
}

async function readWordsFromJson() {
  const raw = await readFile(INPUT_FILE, "utf8");
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.words) || parsed.words.length !== EXPECTED_WORD_COUNT) {
    throw new Error(`Expected data/jlpt-n4-words.json to contain exactly ${EXPECTED_WORD_COUNT} words.`);
  }

  return parsed.words;
}

async function upsertRowChunks(table, rows, conflictColumn = "id") {
  const chunkSize = 200;

  for (let index = 0; index < rows.length; index += chunkSize) {
    const chunk = rows.slice(index, index + chunkSize);
    await upsertRows(table, chunk, conflictColumn);
  }
}

async function main() {
  const words = await readWordsFromJson();
  const categories = buildCategoryRows(words);
  const entries = buildEntryRows(words, categories);
  const structure = buildJlptN4CourseStructure(words);

  await upsertRows("curriculum_languages", [buildLanguageRow()], "slug");
  await upsertRows("curriculum_levels", [buildLevelRow()]);
  await upsertRowChunks("curriculum_modules", structure.modules);
  await upsertRowChunks("curriculum_lessons", structure.lessons);
  await upsertRowChunks("curriculum_vocab_categories", categories);
  await upsertRowChunks("curriculum_vocab_entries", entries);

  console.log(`Upserted ${structure.modules.length} N4 lesson modules.`);
  console.log(`Upserted ${structure.lessons.length} N4 lesson rows.`);
  console.log(`Inserted ${categories.length} N4 vocab categories.`);
  console.log(`Inserted ${entries.length} N4 vocab entries from ${INPUT_FILE}.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
