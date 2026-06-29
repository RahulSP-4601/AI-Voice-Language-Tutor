import {
  type VocabularyCategory,
  type VocabularyEntry,
} from "@/lib/course-types";

export type SupplementalVocabularyBank = Record<
  string,
  [string, string, string][]
>;

function buildEntry(
  seed: [string, string, string],
  categoryId: string,
  index: number,
): VocabularyEntry {
  const [japanese, romaji, english] = seed;
  return {
    english,
    example: `${japanese}をつかったれんしゅうをします。`,
    id: `${categoryId}-supplement-${index + 1}`,
    japanese,
    romaji,
    sortOrder: index + 1,
  };
}

function supplementalEntries(
  bank: SupplementalVocabularyBank,
  categoryId: string,
) {
  return (bank[categoryId] ?? []).map((seed, index) =>
    buildEntry(seed, categoryId, index),
  );
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
