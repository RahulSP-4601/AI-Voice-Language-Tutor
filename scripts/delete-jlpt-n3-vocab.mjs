import { readFile } from "node:fs/promises";
import path from "node:path";
import { loadLocalEnv } from "./load-local-env.mjs";
import { deleteRows } from "./supabase-admin-rest.mjs";

const INPUT_FILE = path.resolve(process.cwd(), "data", "jlpt-n3-words.json");

loadLocalEnv();

function slugify(value) {
  return value
    .toLowerCase()
    .replaceAll(/[^a-z0-9]+/g, "-")
    .replaceAll(/^-+|-+$/g, "");
}

async function readPayload() {
  const raw = await readFile(INPUT_FILE, "utf8");
  return JSON.parse(raw);
}

async function main() {
  const payload = await readPayload();
  const words = Array.isArray(payload.words) ? payload.words : [];
  const categoryIds = Array.from(
    new Set(words.map((word) => `n3-${slugify(word.wordType || "unknown")}`)),
  );

  for (let index = 0; index < words.length; index += 1) {
    const id = `n3-word-${String(index + 1).padStart(4, "0")}`;
    await deleteRows("curriculum_vocab_entries", "id", id);
  }

  for (const categoryId of categoryIds) {
    await deleteRows("curriculum_vocab_categories", "id", categoryId);
  }

  console.log(`Deleted ${words.length} N3 vocab entries.`);
  console.log(`Deleted ${categoryIds.length} N3 vocab categories.`);
  console.log("N3 kanji rows were left intact.");
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
