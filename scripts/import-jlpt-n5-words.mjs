import { readFile } from "node:fs/promises";
import path from "node:path";
import { buildJlptN5CourseStructure } from "./jlpt-n5-course-structure.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";
import { upsertRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n5-words.json");

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
        id: `n5-${slugify(title)}`,
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
    id: `n5-word-${String(index + 1).padStart(4, "0")}`,
    category_id: categoryByTitle.get(word.wordType || "unknown") ?? "n5-unknown",
    language_slug: "japanese",
    japanese: word.japanese,
    romaji: word.reading,
    phonetic_hint: word.phoneticHint || generatePronunciationHint(word.reading),
    english: word.english,
    example: word.example || `${word.japanese} means ${word.english}.`,
    sort_order: index + 1,
  }));
}

function buildLanguageRow() {
  return {
    slug: "japanese",
    name: "Japanese",
    framework_name: "JLPT",
    native_support_label: "English support stays available while the learner speaks each word aloud.",
    hero_summary: "Learn the full JLPT N5 vocabulary journey through 8 speaking lessons built from the live 770-word bank.",
    lesson_duration: "15-20 minute voice lesson",
  };
}

function buildLevelRow() {
  return {
    id: "jp-n5",
    language_slug: "japanese",
    official_label: "N5",
    product_label: "Basic 1",
    objective: "Complete the full JLPT N5 journey by moving lesson by lesson through the 770-word bank with listening, meaning, and speaking practice.",
    exam_title: "JLPT N5 certificate exam",
    pass_requirement: "Finish all 8 lessons and complete the final N5 certificate check.",
    certificate_title: "JLPT N5 completion certificate",
    certificate_summary: "Issued after the learner completes all 8 N5 lessons and clears the certificate checkpoint.",
    sort_order: 0,
  };
}

async function readWordsFromJson() {
  const raw = await readFile(INPUT_FILE, "utf8");
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.words) || parsed.words.length !== 770) {
    throw new Error("Expected data/jlpt-n5-words.json to contain exactly 770 words.");
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
  const structure = buildJlptN5CourseStructure(words);

  await upsertRows("curriculum_languages", [buildLanguageRow()], "slug");
  await upsertRows("curriculum_levels", [buildLevelRow()]);
  await upsertRowChunks("curriculum_modules", structure.modules);
  await upsertRowChunks("curriculum_lessons", structure.lessons);
  await upsertRowChunks("curriculum_vocab_categories", categories);
  await upsertRowChunks("curriculum_vocab_entries", entries);

  console.log(`Upserted ${structure.modules.length} N5 lesson modules.`);
  console.log(`Upserted ${structure.lessons.length} N5 lesson rows.`);
  console.log(`Inserted ${categories.length} vocab categories.`);
  console.log(`Inserted ${entries.length} N5 vocab entries from ${INPUT_FILE}.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
