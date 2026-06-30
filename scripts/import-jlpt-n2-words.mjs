import { readFile } from "node:fs/promises";
import path from "node:path";
import { buildJlptN2CourseStructure } from "./jlpt-n2-course-structure.mjs";
import { deleteRows } from "./supabase-admin-rest.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";
import { upsertRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n2-words.json");
const VOCAB_SORT_OFFSET = 3000;
const GROUP_SIZE = 100;

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
        id: `n2-${slugify(title)}`,
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
    id: `n2-word-${String(index + 1).padStart(4, "0")}`,
    category_id: categoryByTitle.get(word.wordType || "unknown") ?? "n2-unknown",
    language_slug: "japanese",
    japanese: word.japanese,
    romaji: word.reading,
    phonetic_hint: word.phoneticHint || generatePronunciationHint(word.reading),
    english: word.english,
    example: word.example || `${word.japanese} means ${word.english}.`,
    sort_order: VOCAB_SORT_OFFSET + index + 1,
  }));
}

function buildKanjiResources(kanji) {
  const groups = [];
  const entries = [];

  for (let cursor = 0, index = 0; cursor < kanji.length; cursor += GROUP_SIZE, index += 1) {
    const groupId = `n2-kanji-group-${String(index + 1).padStart(2, "0")}`;
    groups.push({
      id: groupId,
      language_slug: "japanese",
      title: `N2 Kanji Group ${index + 1}`,
      sort_order: index,
    });

    kanji.slice(cursor, cursor + GROUP_SIZE).forEach((entry, offset) => {
      entries.push({
        id: `n2-kanji-${String(cursor + offset + 1).padStart(4, "0")}`,
        group_id: groupId,
        language_slug: "japanese",
        japanese: entry.japanese,
        reading: entry.reading,
        phonetic_hint: entry.phoneticHint || generatePronunciationHint(entry.reading),
        meaning: entry.meaning,
        example: entry.example || `${entry.japanese} means ${entry.meaning}.`,
        sort_order: cursor + offset + 1,
      });
    });
  }

  return { entries, groups };
}

function attachKanjiEntries(groups, entries) {
  return groups.map((group) => ({
    ...group,
    entries: entries
      .filter((entry) => entry.group_id === group.id)
      .sort((a, b) => a.sort_order - b.sort_order),
  }));
}

function buildLanguageRow() {
  return {
    slug: "japanese",
    name: "Japanese",
    framework_name: "JLPT",
    native_support_label: "English support stays available while the learner speaks each word aloud.",
    hero_summary: "Learn Japanese through JLPT-aligned speaking lessons that combine advanced vocabulary and kanji into steady listening, meaning, and pronunciation progress.",
    lesson_duration: "15-20 minute voice lesson",
  };
}

function buildLevelRow(vocabLessonCount, kanjiLessonCount) {
  const totalLessonCount = vocabLessonCount + kanjiLessonCount;
  return {
    id: "jp-n2",
    language_slug: "japanese",
    official_label: "N2",
    product_label: "Basic 4",
    objective: `Complete the JLPT N2 journey by finishing ${vocabLessonCount} vocabulary lessons first, then ${kanjiLessonCount} kanji lessons with listening, meaning, and speaking practice.`,
    exam_title: "JLPT N2 certificate exam",
    pass_requirement: `Finish all ${totalLessonCount} lessons and complete the final N2 certificate check.`,
    certificate_title: "JLPT N2 completion certificate",
    certificate_summary: `Issued after the learner completes all ${totalLessonCount} N2 lessons and clears the certificate checkpoint.`,
    sort_order: 3,
  };
}

async function readPayload() {
  const raw = await readFile(INPUT_FILE, "utf8");
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.words) || parsed.words.length === 0) {
    throw new Error("Expected data/jlpt-n2-words.json to contain extracted N2 vocabulary words.");
  }

  if (!Array.isArray(parsed.kanji) || parsed.kanji.length === 0) {
    throw new Error("Expected data/jlpt-n2-words.json to contain extracted N2 kanji entries.");
  }

  return parsed;
}

async function upsertRowChunks(table, rows, conflictColumn = "id") {
  const chunkSize = 200;

  for (let index = 0; index < rows.length; index += chunkSize) {
    await upsertRows(table, rows.slice(index, index + chunkSize), conflictColumn);
  }
}

async function main() {
  const payload = await readPayload();
  const words = payload.words;
  const kanji = payload.kanji;
  const categories = buildCategoryRows(words);
  const entries = buildEntryRows(words, categories);
  const kanjiResources = buildKanjiResources(kanji);
  const groupedKanji = attachKanjiEntries(kanjiResources.groups, kanjiResources.entries);
  const structure = buildJlptN2CourseStructure(words, groupedKanji);

  await deleteRows("curriculum_lessons", "level_id", "jp-n2");
  await deleteRows("curriculum_modules", "level_id", "jp-n2");
  await deleteRows("curriculum_modules", "id", "jp-n2-roadmap");

  await upsertRows("curriculum_languages", [buildLanguageRow()], "slug");
  await upsertRows("curriculum_levels", [buildLevelRow(Math.ceil(words.length / GROUP_SIZE), groupedKanji.length)]);
  await upsertRowChunks("curriculum_modules", structure.modules);
  await upsertRowChunks("curriculum_lessons", structure.lessons);
  await upsertRowChunks("curriculum_vocab_categories", categories);
  await upsertRowChunks("curriculum_vocab_entries", entries);
  await upsertRowChunks("curriculum_kanji_groups", kanjiResources.groups);
  await upsertRowChunks("curriculum_kanji_entries", kanjiResources.entries);

  console.log(`Upserted ${structure.modules.length} N2 lesson modules.`);
  console.log(`Upserted ${structure.lessons.length} N2 lesson rows.`);
  console.log(`Inserted ${categories.length} N2 vocab categories.`);
  console.log(`Inserted ${entries.length} N2 vocab entries from ${INPUT_FILE}.`);
  console.log(`Inserted ${kanjiResources.groups.length} N2 kanji groups.`);
  console.log(`Inserted ${kanjiResources.entries.length} N2 kanji entries.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
