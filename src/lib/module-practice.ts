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

function hashValue(value: string) {
  return Array.from(value).reduce(
    (sum, char) => sum + char.charCodeAt(0),
    0,
  );
}

function tokenize(value: string) {
  return normalize(value)
    .split(/\s+/)
    .filter((token) => token.length > 2);
}

function moduleSignals(module: CourseModule) {
  return Array.from(
    new Set(
      [
        module.title,
        module.objective,
        module.checkpointLabel,
        ...module.experience.coverage,
        ...module.lessons.flatMap((lesson) => [
          lesson.title,
          lesson.demoPhrase,
          lesson.replyPrompt,
          lesson.targetPattern,
          lesson.learnerOutcome,
          ...lesson.acceptableResponses,
        ]),
      ].flatMap(tokenize),
    ),
  );
}

function pickFallbackWindow<T>(items: T[], key: string, size: number) {
  if (items.length <= size) {
    return items;
  }

  const start = hashValue(key) % items.length;
  return Array.from({ length: size }, (_, index) => items[(start + index) % items.length]);
}

function cardText(card: PracticeCard) {
  return [card.japanese, card.reading, card.english, card.example].map(normalize).join(" ");
}

function matchesSignal(card: PracticeCard, signals: string[]) {
  const haystack = cardText(card);
  return signals.some((signal) => haystack.includes(signal));
}

function dedupeCards(cards: PracticeCard[]) {
  return Array.from(new Map(cards.map((card) => [card.id, card])).values());
}

function linkedWordCards(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  return linkedVocabulary(resources, module);
}

function linkedKanjiCards(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  return linkedKanji(resources, module);
}

function targetedCards(cards: PracticeCard[], signals: string[]) {
  return dedupeCards(cards.filter((card) => matchesSignal(card, signals)));
}

function supplementCards(
  focused: PracticeCard[],
  fallback: PracticeCard[],
  moduleId: string,
  size: number,
) {
  const existing = new Set(focused.map((card) => card.id));
  const remaining = fallback.filter((card) => !existing.has(card.id));
  return dedupeCards([...focused, ...pickFallbackWindow(remaining, moduleId, size)]);
}

function buildModuleWords(
  resources: LanguageCourseResources,
  module: CourseModule,
  signals: string[],
) {
  const linked = linkedWordCards(resources, module);
  const allCards = resources.vocabularyCategories.flatMap((category) =>
    wordCards(category.entries, category.title),
  );
  const focused = targetedCards(allCards, signals);
  return supplementCards(focused, linked, `${module.id}:words`, 6);
}

function buildModuleKanji(
  resources: LanguageCourseResources,
  module: CourseModule,
  signals: string[],
) {
  const linked = linkedKanjiCards(resources, module);
  if (!linked.length) {
    return [];
  }

  const allCards = resources.kanjiGroups.flatMap((group) =>
    kanjiCards(group.entries, group.title),
  );
  const focused = targetedCards(allCards, signals);
  return supplementCards(focused, linked, `${module.id}:kanji`, 4);
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

  const signals = moduleSignals(module);
  return [
    ...buildModuleWords(resources, module, signals),
    ...buildModuleKanji(resources, module, signals),
  ];
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
    return 100;
  }

  if (targets.some((target) => isNearExactMatch(target, value))) {
    return 84;
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
