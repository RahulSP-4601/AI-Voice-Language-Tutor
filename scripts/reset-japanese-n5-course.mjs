import { loadLocalEnv } from "./load-local-env.mjs";
import { deleteRows } from "./supabase-admin-rest.mjs";

loadLocalEnv();

async function main() {
  const languageSlug = "japanese";
  const levelId = "jp-n5";

  await deleteRows("user_level_certificates", "level_id", levelId);
  await deleteRows("user_module_attempts", "language_slug", languageSlug);
  await deleteRows("user_practice_item_progress", "language_slug", languageSlug);
  await deleteRows("user_module_progress", "language_slug", languageSlug);
  await deleteRows("curriculum_exam_questions", "language_slug", languageSlug);
  await deleteRows("curriculum_exam_sections", "language_slug", languageSlug);
  await deleteRows("curriculum_kanji_entries", "language_slug", languageSlug);
  await deleteRows("curriculum_kanji_groups", "language_slug", languageSlug);
  await deleteRows("curriculum_vocab_entries", "language_slug", languageSlug);
  await deleteRows("curriculum_vocab_categories", "language_slug", languageSlug);
  await deleteRows("curriculum_lessons", "level_id", levelId);
  await deleteRows("curriculum_modules", "level_id", levelId);

  console.log("Deleted the existing Japanese N5 course, vocab, kanji, and exam rows.");
  console.log("The language and level records were left in place.");
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
