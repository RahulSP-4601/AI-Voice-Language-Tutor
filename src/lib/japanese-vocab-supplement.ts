import {
  type VocabularyCategory,
  type VocabularyEntry,
} from "@/lib/course-types";

export type SupplementalVocabularyBank = Record<
  string,
  [string, string, string][]
>;

function buildEntry(seed: [string, string, string]): VocabularyEntry {
  const [japanese, romaji, english] = seed;
  return {
    english,
    example: `${japanese}をつかったれんしゅうをします。`,
    japanese,
    romaji,
  };
}

function supplementalEntries(
  bank: SupplementalVocabularyBank,
  categoryId: string,
) {
  return (bank[categoryId] ?? []).map(buildEntry);
}

export function mergeVocabularyBank(
  categories: VocabularyCategory[],
  bank: SupplementalVocabularyBank,
) {
  return categories.map((category) => ({
    ...category,
    entries: [...category.entries, ...supplementalEntries(bank, category.id)],
  }));
}
