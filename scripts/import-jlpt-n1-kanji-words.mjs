import { readFile } from "node:fs/promises";
import path from "node:path";
import { buildJlptN1CourseStructure } from "./jlpt-n1-course-structure.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";
import { deleteRows, upsertRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n1-kanji.json");
const GROUP_SIZE = 100;
const GROUP_ID_PREFIX = "n1-kanji-group-";
const VOCAB_CATEGORY_PREFIX = "n1-";

loadLocalEnv();

function buildHeaders() {
  const baseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!baseUrl || !serviceRoleKey) {
    throw new Error("Missing Supabase environment variables for N1 kanji import.");
  }

  return {
    baseUrl,
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
    },
  };
}

function normalizeKey(value) {
  return String(value ?? "").replace(/\s+/g, " ").trim();
}

function buildExistingKey(entry) {
  return normalizeKey(entry.japanese);
}

async function fetchExistingJapaneseKanji() {
  const { baseUrl, headers } = buildHeaders();
  const rows = [];
  const pageSize = 1000;

  for (let start = 0; ; start += pageSize) {
    const url = new URL("/rest/v1/curriculum_kanji_entries", baseUrl);
    url.searchParams.set("select", "japanese,group_id");
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
      throw new Error(`Failed reading existing Japanese kanji rows: ${text}`);
    }

    const batch = text ? JSON.parse(text) : [];
    rows.push(...batch);
    if (batch.length < pageSize) {
      return rows.filter((row) => !String(row.group_id || "").startsWith(GROUP_ID_PREFIX));
    }
  }
}

async function fetchExistingN1VocabEntries() {
  const { baseUrl, headers } = buildHeaders();
  const rows = [];
  const pageSize = 1000;

  for (let start = 0; ; start += pageSize) {
    const url = new URL("/rest/v1/curriculum_vocab_entries", baseUrl);
    url.searchParams.set("select", "japanese,romaji,category_id,sort_order");
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
      throw new Error(`Failed reading existing N1 vocab rows: ${text}`);
    }

    const batch = text ? JSON.parse(text) : [];
    rows.push(...batch);
    if (batch.length < pageSize) {
      return rows.filter((row) => String(row.category_id || "").startsWith(VOCAB_CATEGORY_PREFIX));
    }
  }
}

async function readPayload() {
  const raw = await readFile(INPUT_FILE, "utf8");
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.kanji) || parsed.kanji.length === 0) {
    throw new Error("Expected data/jlpt-n1-kanji.json to contain extracted N1 kanji entries.");
  }

  return parsed.kanji;
}

function filterNewKanji(rows, existingEntries) {
  const existingKeys = new Set(existingEntries.map(buildExistingKey));
  const filtered = [];
  const skipped = [];

  for (const row of rows) {
    const key = buildExistingKey(row);
    if (existingKeys.has(key)) {
      skipped.push(row);
      continue;
    }
    existingKeys.add(key);
    filtered.push(row);
  }

  return { filtered, skipped };
}

function buildKanjiResources(rows) {
  const groups = [];
  const entries = [];

  for (let cursor = 0, index = 0; cursor < rows.length; cursor += GROUP_SIZE, index += 1) {
    const groupId = `${GROUP_ID_PREFIX}${String(index + 1).padStart(2, "0")}`;
    groups.push({
      id: groupId,
      language_slug: "japanese",
      title: `N1 Kanji Group ${index + 1}`,
      sort_order: index,
    });

    rows.slice(cursor, cursor + GROUP_SIZE).forEach((row, offset) => {
      entries.push({
        id: `n1-kanji-${String(cursor + offset + 1).padStart(4, "0")}`,
        group_id: groupId,
        language_slug: "japanese",
        japanese: row.japanese,
        reading: row.reading,
        phonetic_hint: row.phoneticHint,
        meaning: row.meaning,
        example: row.example || `${row.japanese} means ${row.meaning}.`,
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

function buildLevelRow(vocabLessonCount, kanjiLessonCount, vocabCount, kanjiCount, skippedCount) {
  const totalLessonCount = vocabLessonCount + kanjiLessonCount;
  return {
    id: "jp-n1",
    language_slug: "japanese",
    official_label: "N1",
    product_label: "JLPT Level",
    objective: `Complete the JLPT N1 journey by finishing ${vocabLessonCount} vocabulary lessons first, then ${kanjiLessonCount} kanji lessons across ${vocabCount + kanjiCount} total words.`,
    exam_title: "JLPT N1 certificate exam",
    pass_requirement: `Finish all ${totalLessonCount} lessons and complete the final N1 certificate check.`,
    certificate_title: "JLPT N1 completion certificate",
    certificate_summary: `Issued after the learner completes all ${totalLessonCount} N1 lessons and clears the certificate checkpoint. ${skippedCount} duplicate kanji were skipped during import.`,
    sort_order: 4,
  };
}

async function clearExistingN1Kanji() {
  for (let index = 1; index <= 20; index += 1) {
    const groupId = `${GROUP_ID_PREFIX}${String(index).padStart(2, "0")}`;
    await deleteRows("curriculum_kanji_entries", "group_id", groupId);
    await deleteRows("curriculum_kanji_groups", "id", groupId);
  }
}

async function upsertRowChunks(table, rows, conflictColumn = "id") {
  const chunkSize = 200;

  for (let index = 0; index < rows.length; index += chunkSize) {
    await upsertRows(table, rows.slice(index, index + chunkSize), conflictColumn);
  }
}

async function main() {
  const extractedRows = await readPayload();
  const existingEntries = await fetchExistingJapaneseKanji();
  const vocabEntries = await fetchExistingN1VocabEntries();
  const { filtered, skipped } = filterNewKanji(extractedRows, existingEntries);

  if (filtered.length === 0) {
    throw new Error("All extracted N1 kanji already exist in the database. Nothing new to import.");
  }

  const resources = buildKanjiResources(filtered);
  const groupedKanji = attachKanjiEntries(resources.groups, resources.entries);
  const structure = buildJlptN1CourseStructure(vocabEntries, groupedKanji);
  const vocabLessonCount = Math.ceil(vocabEntries.length / GROUP_SIZE);

  await clearExistingN1Kanji();
  await deleteRows("curriculum_lessons", "level_id", "jp-n1");
  await deleteRows("curriculum_modules", "level_id", "jp-n1");
  await deleteRows("curriculum_modules", "id", "jp-n1-roadmap");

  await upsertRows(
    "curriculum_levels",
    [buildLevelRow(vocabLessonCount, groupedKanji.length, vocabEntries.length, resources.entries.length, skipped.length)],
  );
  await upsertRowChunks("curriculum_modules", structure.modules);
  await upsertRowChunks("curriculum_lessons", structure.lessons);
  await upsertRowChunks("curriculum_kanji_groups", resources.groups);
  await upsertRowChunks("curriculum_kanji_entries", resources.entries);

  console.log(`Upserted ${structure.modules.length} N1 lesson modules.`);
  console.log(`Upserted ${structure.lessons.length} N1 lesson rows.`);
  console.log(`Inserted ${resources.groups.length} N1 kanji groups.`);
  console.log(`Inserted ${resources.entries.length} N1 kanji entries from ${INPUT_FILE}.`);
  console.log(`Skipped ${skipped.length} N1 kanji because they already existed in Japanese kanji.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
