import {
  type CourseLesson,
  type CourseModule,
  type KanjiEntry,
  type LanguageCourseResources,
  type VocabularyEntry,
} from "@/lib/course-definitions";

export type PracticeKind = "kanji" | "word";

export type PracticeCard = {
  english: string;
  example: string;
  id: string;
  japanese: string;
  kind: PracticeKind;
  reading: string;
  title: string;
};

function normalize(value: string) {
  return value.toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, "").trim();
}

function buildScopeKey(title: string) {
  return normalize(title).replace(/\s+/g, "-");
}

function buildWordId(entry: VocabularyEntry, title: string) {
  return `word:${buildScopeKey(title)}:${entry.japanese}:${entry.romaji}`;
}

function buildKanjiId(entry: KanjiEntry, title: string) {
  return `kanji:${buildScopeKey(title)}:${entry.japanese}:${entry.reading}`;
}

function wordCards(entries: VocabularyEntry[], title: string) {
  return entries.map((entry) => ({
    english: entry.english,
    example: entry.example,
    id: buildWordId(entry, title),
    japanese: entry.japanese,
    kind: "word" as const,
    reading: entry.romaji,
    title,
  }));
}

function kanjiCards(entries: KanjiEntry[], title: string) {
  return entries.map((entry) => ({
    english: entry.meaning,
    example: entry.example,
    id: buildKanjiId(entry, title),
    japanese: entry.japanese,
    kind: "kanji" as const,
    reading: entry.reading,
    title,
  }));
}

function linkedVocabulary(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.vocabularyCategoryIds;
  const categories = ids?.length
    ? resources.vocabularyCategories.filter((item) => ids.includes(item.id))
    : resources.vocabularyCategories.slice(0, 3);
  return categories.flatMap((category) => wordCards(category.entries, category.title));
}

function linkedKanji(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.kanjiGroupIds;
  const groups = ids?.length
    ? resources.kanjiGroups.filter((item) => ids.includes(item.id))
    : resources.kanjiGroups.slice(0, 2);
  return groups.flatMap((group) => kanjiCards(group.entries, group.title));
}

function lessonCandidates(lesson: CourseLesson) {
  return [lesson.demoPhrase, ...lesson.acceptableResponses].map(normalize);
}

function cardCandidates(card: PracticeCard) {
  return [card.japanese, card.reading, card.english, card.example].map(normalize);
}

export function buildPracticeCards(
  module: CourseModule,
  resources?: LanguageCourseResources,
) {
  if (!resources) {
    return [] as PracticeCard[];
  }

  return [...linkedVocabulary(resources, module), ...linkedKanji(resources, module)];
}

export function findLessonMeaning(
  lesson: CourseLesson,
  cards: PracticeCard[],
) {
  const lessonValues = lessonCandidates(lesson);
  const match = cards.find((card) =>
    cardCandidates(card).some((value) => lessonValues.includes(value)),
  );
  return match ? `${match.english} (${match.reading})` : fallbackLessonMeaning(lesson);
}

function fallbackLessonMeaning(lesson: CourseLesson) {
  const title = lesson.title.match(/^What is (.+)\?$/i)?.[1];
  return title ? `${title} (${lesson.demoPhrase})` : null;
}

export function scorePracticeTranscript(expected: PracticeCard, transcript: string) {
  const value = normalize(transcript);
  if (!value) {
    return 0;
  }

  const targets = [expected.japanese, expected.reading].map(normalize);
  if (targets.includes(value)) {
    return 98;
  }

  if (targets.some((target) => isNearExactMatch(target, value))) {
    return 90;
  }

  return 0;
}

function isNearExactMatch(target: string, value: string) {
  if (Math.abs(target.length - value.length) > 1) {
    return false;
  }

  if (!sameWordCount(target, value)) {
    return false;
  }

  return withinSingleEdit(target, value);
}

function sameWordCount(left: string, right: string) {
  return left.split(/\s+/).length === right.split(/\s+/).length;
}

function withinSingleEdit(left: string, right: string) {
  if (left === right) {
    return true;
  }

  let i = 0;
  let j = 0;
  let edits = 0;

  while (i < left.length && j < right.length) {
    if (left[i] === right[j]) {
      i += 1;
      j += 1;
      continue;
    }

    edits += 1;
    if (edits > 1) {
      return false;
    }

    if (left.length > right.length) {
      i += 1;
    } else if (right.length > left.length) {
      j += 1;
    } else {
      i += 1;
      j += 1;
    }
  }

  if (i < left.length || j < right.length) {
    edits += 1;
  }

  return edits <= 1;
}
