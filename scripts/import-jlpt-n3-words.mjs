import { readFile } from "node:fs/promises";
import path from "node:path";
import { buildJlptN3CourseStructure } from "./jlpt-n3-course-structure.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";
import { generatePronunciationHint } from "./pronunciation-hint.mjs";
import { upsertRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n3-words.json");
const EXPECTED_KANJI_COUNT = 100;
const VOCAB_SORT_OFFSET = 2000;
const KANJI_GROUP_COUNT = 1;

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
        id: `n3-${slugify(title)}`,
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
    id: `n3-word-${String(index + 1).padStart(4, "0")}`,
    category_id: categoryByTitle.get(word.wordType || "unknown") ?? "n3-unknown",
    language_slug: "japanese",
    japanese: word.japanese,
    romaji: word.reading,
    phonetic_hint: word.phoneticHint || generatePronunciationHint(word.reading),
    english: word.english,
    example: word.example || `${word.japanese} means ${word.english}.`,
    sort_order: VOCAB_SORT_OFFSET + index + 1,
  }));
}

function buildKanjiGroups(kanji) {
  const baseSize = Math.floor(kanji.length / KANJI_GROUP_COUNT);
  const remainder = kanji.length % KANJI_GROUP_COUNT;
  const groups = [];
  const entries = [];
  let cursor = 0;

  for (let index = 0; index < KANJI_GROUP_COUNT; index += 1) {
    const size = baseSize + (index < remainder ? 1 : 0);
    const groupId = `n3-kanji-group-${String(index + 1).padStart(2, "0")}`;
    groups.push({
      id: groupId,
      language_slug: "japanese",
      title: `N3 Kanji Group ${index + 1}`,
      sort_order: index,
    });

    const slice = kanji.slice(cursor, cursor + size);
    slice.forEach((entry, entryIndex) => {
      entries.push({
        id: `n3-kanji-${String(cursor + entryIndex + 1).padStart(4, "0")}`,
        group_id: groupId,
        language_slug: "japanese",
        japanese: entry.japanese,
        reading: entry.reading,
        phonetic_hint: entry.phoneticHint || generatePronunciationHint(entry.reading),
        meaning: entry.meaning,
        example: entry.example || `${entry.japanese} means ${entry.meaning}.`,
        sort_order: cursor + entryIndex + 1,
      });
    });

    cursor += size;
  }

  return { entries, groups };
}

function attachKanjiEntriesToGroups(groups, entries) {
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
    hero_summary: "Learn Japanese through JLPT-aligned speaking lessons that combine vocabulary and kanji into steady listening, meaning, and pronunciation progress.",
    lesson_duration: "15-20 minute voice lesson",
  };
}

function buildLevelRow() {
  return {
    id: "jp-n3",
    language_slug: "japanese",
    official_label: "N3",
    product_label: "Basic 3",
    objective: "Complete the JLPT N3 journey by finishing 8 vocabulary lessons first, then 1 kanji lesson with listening, meaning, and speaking practice.",
    exam_title: "JLPT N3 certificate exam",
    pass_requirement: "Finish all 9 lessons and complete the final N3 certificate check.",
    certificate_title: "JLPT N3 completion certificate",
    certificate_summary: "Issued after the learner completes all 9 N3 lessons and clears the certificate checkpoint.",
    sort_order: 2,
  };
}

async function readPayload() {
  const raw = await readFile(INPUT_FILE, "utf8");
  const parsed = JSON.parse(raw);
  const expectedWordCount = Number(parsed?.counts?.words ?? 0);

  if (!Array.isArray(parsed.words) || parsed.words.length === 0) {
    throw new Error("Expected data/jlpt-n3-words.json to contain extracted N3 vocabulary words.");
  }

  if (expectedWordCount > 0 && parsed.words.length !== expectedWordCount) {
    throw new Error(
      `Expected data/jlpt-n3-words.json to contain exactly ${expectedWordCount} words, found ${parsed.words.length}.`,
    );
  }

  if (!Array.isArray(parsed.kanji) || parsed.kanji.length !== EXPECTED_KANJI_COUNT) {
    throw new Error(`Expected data/jlpt-n3-words.json to contain exactly ${EXPECTED_KANJI_COUNT} kanji entries.`);
  }

  return parsed;
}

async function upsertRowChunks(table, rows, conflictColumn = "id") {
  const chunkSize = 200;

  for (let index = 0; index < rows.length; index += chunkSize) {
    const chunk = rows.slice(index, index + chunkSize);
    await upsertRows(table, chunk, conflictColumn);
  }
}

async function main() {
  const payload = await readPayload();
  const words = payload.words;
  const kanji = payload.kanji;
  const categories = buildCategoryRows(words);
  const entries = buildEntryRows(words, categories);
  const kanjiResources = buildKanjiGroups(kanji);
  const structure = buildJlptN3CourseStructure(
    words,
    attachKanjiEntriesToGroups(kanjiResources.groups, kanjiResources.entries)[0],
  );

  await upsertRows("curriculum_languages", [buildLanguageRow()], "slug");
  await upsertRows("curriculum_levels", [buildLevelRow()]);
  await upsertRowChunks("curriculum_modules", structure.modules);
  await upsertRowChunks("curriculum_lessons", structure.lessons);
  await upsertRowChunks("curriculum_vocab_categories", categories);
  await upsertRowChunks("curriculum_vocab_entries", entries);
  await upsertRowChunks("curriculum_kanji_groups", kanjiResources.groups);
  await upsertRowChunks("curriculum_kanji_entries", kanjiResources.entries);

  console.log(`Upserted ${structure.modules.length} N3 lesson modules.`);
  console.log(`Upserted ${structure.lessons.length} N3 lesson rows.`);
  console.log(`Inserted ${categories.length} N3 vocab categories.`);
  console.log(`Inserted ${entries.length} N3 vocab entries from ${INPUT_FILE}.`);
  console.log(`Inserted ${kanjiResources.groups.length} N3 kanji groups.`);
  console.log(`Inserted ${kanjiResources.entries.length} N3 kanji entries.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
