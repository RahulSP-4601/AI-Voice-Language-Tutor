import { readFile } from "node:fs/promises";
import path from "node:path";
import { deleteRows } from "./supabase-admin-rest.mjs";
import { loadLocalEnv } from "./load-local-env.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n2-words.json");
const LEVEL_ID = "jp-n2";

loadLocalEnv();

function sliceCount(total, size) {
  return Math.ceil(total / size);
}

async function readPayload() {
  const raw = await readFile(INPUT_FILE, "utf8");
  return JSON.parse(raw);
}

async function deleteByIds(table, ids) {
  for (const id of ids) {
    await deleteRows(table, "id", id);
  }
}

async function main() {
  const payload = await readPayload();
  const words = Array.isArray(payload.words) ? payload.words : [];
  const kanji = Array.isArray(payload.kanji) ? payload.kanji : [];
  const vocabLessonCount = sliceCount(words.length, 100);
  const kanjiGroupCount = sliceCount(kanji.length, 100);
  const totalLessonCount = vocabLessonCount + kanjiGroupCount;

  await deleteByIds(
    "curriculum_vocab_entries",
    words.map((_, index) => `n2-word-${String(index + 1).padStart(4, "0")}`),
  );
  await deleteRows("curriculum_vocab_categories", "id", "n2-vocabulary");

  await deleteByIds(
    "curriculum_kanji_entries",
    kanji.map((_, index) => `n2-kanji-${String(index + 1).padStart(4, "0")}`),
  );
  await deleteByIds(
    "curriculum_kanji_groups",
    Array.from(
      { length: kanjiGroupCount },
      (_, index) => `n2-kanji-group-${String(index + 1).padStart(2, "0")}`,
    ),
  );

  await deleteRows("curriculum_lessons", "level_id", LEVEL_ID);
  await deleteRows("curriculum_modules", "level_id", LEVEL_ID);
  await deleteRows("curriculum_modules", "id", "jp-n2-roadmap");

  console.log(`Deleted ${words.length} N2 vocab entries.`);
  console.log(`Deleted ${kanji.length} N2 kanji entries.`);
  console.log(`Deleted ${kanjiGroupCount} N2 kanji groups.`);
  console.log(`Deleted N2 lesson/module rows for ${totalLessonCount} lessons.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
