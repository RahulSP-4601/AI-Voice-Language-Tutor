import {
  type CourseLesson,
  type CourseSlug,
  type CourseModule,
  type KanjiEntry,
  type LanguageCourseDefinition,
  type LanguageCourseResources,
  type VocabularyEntry,
} from "@/lib/course-definitions";
import { scoreSpeechAttempt } from "@/lib/language-speech";
import { generatePronunciationHint } from "@/lib/pronunciation-hint";

export type PracticeKind = "kanji" | "word";

export type PracticeCard = {
  english: string;
  example: string;
  id: string;
  japanese: string;
  kind: PracticeKind;
  phoneticHint: string;
  reading: string;
  sortOrder: number;
  title: string;
};

export type ModulePracticeDeck = {
  all: PracticeCard[];
  kanji: PracticeCard[];
  words: PracticeCard[];
};

export const PRACTICE_PASS_SCORE = 75;

function normalize(value: string) {
  return value.toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, "").trim();
}

function buildWordId(entry: VocabularyEntry) {
  return `word:${normalize(entry.japanese)}:${normalize(entry.romaji)}`;
}

function buildKanjiId(entry: KanjiEntry) {
  return `kanji:${normalize(entry.japanese)}:${normalize(entry.reading)}`;
}

function wordCards(entries: VocabularyEntry[], title: string) {
  return entries.map((entry) => ({
    english: entry.english,
    example: entry.example,
    id: buildWordId(entry),
    japanese: entry.japanese,
    kind: "word" as const,
    phoneticHint: entry.phoneticHint || generatePronunciationHint(entry.romaji),
    reading: entry.romaji,
    sortOrder: entry.sortOrder,
    title,
  }));
}

function kanjiCards(entries: KanjiEntry[], title: string) {
  return entries.map((entry) => ({
    english: entry.meaning,
    example: entry.example,
    id: buildKanjiId(entry),
    japanese: entry.japanese,
    kind: "kanji" as const,
    phoneticHint: entry.phoneticHint || generatePronunciationHint(entry.reading),
    reading: entry.reading,
    sortOrder: entry.sortOrder,
    title,
  }));
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

function cardText(card: PracticeCard) {
  return [card.japanese, card.reading, card.english, card.example]
    .map(normalize)
    .join(" ");
}

function matchesSignal(card: PracticeCard, signals: string[]) {
  const haystack = cardText(card);
  return signals.some((signal) => haystack.includes(signal));
}

function dedupeCards(cards: PracticeCard[]) {
  return Array.from(new Map(cards.map((card) => [card.id, card])).values());
}

function allWordCards(resources: LanguageCourseResources) {
  return resources.vocabularyCategories
    .flatMap((category) => wordCards(category.entries, category.title))
    .sort((a, b) => a.sortOrder - b.sortOrder);
}

function rangeCards(cards: PracticeCard[], ranges?: Array<{ end: number; start: number }>) {
  if (!ranges?.length) {
    return [];
  }

  return cards.filter((card) =>
    ranges.some((range) => card.sortOrder >= range.start && card.sortOrder <= range.end),
  );
}

function linkedWordCards(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.vocabularyCategoryIds;
  if (!ids?.length) return [];
  return resources.vocabularyCategories
    .filter((item) => ids.includes(item.id))
    .flatMap((category) => wordCards(category.entries, category.title));
}

function linkedKanjiCards(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.kanjiGroupIds;
  if (!ids?.length) return [];
  return resources.kanjiGroups
    .filter((item) => ids.includes(item.id))
    .flatMap((group) => kanjiCards(group.entries, group.title));
}

function hashValue(value: string) {
  return Array.from(value).reduce(
    (sum, char) => sum + char.charCodeAt(0),
    0,
  );
}

function pickFallbackWindow<T extends PracticeCard>(
  items: T[],
  key: string,
  size: number,
) {
  if (items.length <= size) {
    return items;
  }

  const start = hashValue(key) % items.length;
  return Array.from(
    { length: size },
    (_, index) => items[(start + index) % items.length],
  );
}

function targetedCards(cards: PracticeCard[], signals: string[]) {
  return dedupeCards(cards.filter((card) => matchesSignal(card, signals)));
}

function moduleWordCandidates(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ranged = dedupeCards(
    rangeCards(allWordCards(resources), module.resourceLinks?.vocabularyRanges),
  );
  if (ranged.length) return ranged;

  const linked = dedupeCards(linkedWordCards(resources, module));
  if (linked.length) return linked;

  const all = allWordCards(resources);
  const focused = targetedCards(all, moduleSignals(module));
  return focused.length ? focused : pickFallbackWindow(all, module.id, 12);
}

function moduleKanjiCandidates(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const linked = dedupeCards(linkedKanjiCards(resources, module));
  if (linked.length) return linked;
  return [];
}

function hasExplicitPracticeResources(module: CourseModule) {
  return Boolean(
    module.resourceLinks?.vocabularyRanges?.length ||
      module.resourceLinks?.vocabularyCategoryIds?.length ||
      module.resourceLinks?.kanjiGroupIds?.length,
  );
}

function orderedModules(course: LanguageCourseDefinition) {
  return course.framework.levels.flatMap((level) => level.modules);
}

function takeUnseen(cards: PracticeCard[], seenIds: Set<string>) {
  return cards.filter((card) => !seenIds.has(card.id));
}

function remember(cards: PracticeCard[], seenIds: Set<string>) {
  cards.forEach((card) => seenIds.add(card.id));
}

function buildDeck(words: PracticeCard[], kanji: PracticeCard[]) {
  return {
    all: [...words, ...kanji],
    kanji,
    words,
  } satisfies ModulePracticeDeck;
}

export function buildCoursePracticeMap(
  course: LanguageCourseDefinition,
) {
  const resources = course.resources;
  if (!resources) {
    return {} as Record<string, ModulePracticeDeck>;
  }

  const seenWordIds = new Set<string>();
  const seenKanjiIds = new Set<string>();

  return Object.fromEntries(
    orderedModules(course).map((module) => {
      const words = moduleWordCandidates(resources, module);
      const kanji = moduleKanjiCandidates(resources, module);

      if (hasExplicitPracticeResources(module)) {
        return [module.id, buildDeck(words, kanji)];
      }

      const unseenWords = takeUnseen(words, seenWordIds);
      const unseenKanji = takeUnseen(kanji, seenKanjiIds);
      remember(unseenWords, seenWordIds);
      remember(unseenKanji, seenKanjiIds);
      return [module.id, buildDeck(unseenWords, unseenKanji)];
    }),
  );
}

export function buildModulePracticeCards(
  course: LanguageCourseDefinition,
  moduleId: string,
) {
  return buildCoursePracticeMap(course)[moduleId] ?? buildDeck([], []);
}

function lessonCandidates(lesson: CourseLesson) {
  return [lesson.demoPhrase, ...lesson.acceptableResponses].map(normalize);
}

function cardCandidates(card: PracticeCard) {
  return [card.japanese, card.reading, card.english, card.example].map(normalize);
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

export function scorePracticeTranscript(
  expected: PracticeCard,
  transcript: string,
  slug: CourseSlug,
) {
  return scoreSpeechAttempt(slug, transcript, [
    expected.japanese,
    expected.reading,
    expected.phoneticHint,
  ]);
}
