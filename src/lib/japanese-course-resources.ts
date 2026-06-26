import { type LanguageCourseResources, type ResourceLinkSet } from "@/lib/course-types";
import { japaneseVocabularyBankA } from "@/lib/japanese-course-resources-a";
import { japaneseVocabularyBankB } from "@/lib/japanese-course-resources-b";
import { japaneseVocabularyBankC } from "@/lib/japanese-course-resources-c";
import { japaneseVocabularyBankD } from "@/lib/japanese-course-resources-d";
import { japaneseVocabularyExtraA } from "@/lib/japanese-course-resources-extra-a";
import { japaneseVocabularyExtraB } from "@/lib/japanese-course-resources-extra-b";
import { japaneseVocabularyExtraC } from "@/lib/japanese-course-resources-extra-c";
import { japaneseVocabularyExtraD } from "@/lib/japanese-course-resources-extra-d";
import { japaneseVocabularyExtraE } from "@/lib/japanese-course-resources-extra-e";
import { japaneseVocabularyExtraF } from "@/lib/japanese-course-resources-extra-f";
import { japaneseVocabularyExtraG } from "@/lib/japanese-course-resources-extra-g";
import { japaneseKanjiBank } from "@/lib/japanese-kanji-bank";
import { japaneseExamDataset } from "@/lib/japanese-exam-dataset";
import { japaneseQuestionBankA } from "@/lib/japanese-question-bank-a";
import { japaneseQuestionBankB } from "@/lib/japanese-question-bank-b";
import { japaneseQuestionBankC } from "@/lib/japanese-question-bank-c";
import { mergeVocabularyBank } from "@/lib/japanese-vocab-supplement";

const japaneseVocabularySupplement = {
  ...japaneseVocabularyExtraA,
  ...japaneseVocabularyExtraB,
  ...japaneseVocabularyExtraC,
  ...japaneseVocabularyExtraD,
  ...japaneseVocabularyExtraE,
  ...japaneseVocabularyExtraF,
  ...japaneseVocabularyExtraG,
};

export const japaneseCourseResources: LanguageCourseResources = {
  examQuestions: [
    ...japaneseQuestionBankA,
    ...japaneseQuestionBankB,
    ...japaneseQuestionBankC,
  ],
  examSections: [...japaneseExamDataset],
  kanjiGroups: [...japaneseKanjiBank],
  vocabularyCategories: mergeVocabularyBank(
    [
      ...japaneseVocabularyBankA,
      ...japaneseVocabularyBankB,
      ...japaneseVocabularyBankC,
      ...japaneseVocabularyBankD,
    ],
    japaneseVocabularySupplement,
  ),
};

const defaultExam = ["sounds-romaji", "vocabulary", "speaking"];

function allExamIds() {
  return japaneseCourseResources.examSections.map((section) => section.id);
}

function allKanjiIds() {
  return japaneseCourseResources.kanjiGroups.map((group) => group.id);
}

function allVocabIds() {
  return japaneseCourseResources.vocabularyCategories.map((category) => category.id);
}

function hasAnyKeyword(moduleId: string, keywords: string[]) {
  return keywords.some((keyword) => moduleId.includes(keyword));
}

function createLinks(config: ResourceLinkSet): ResourceLinkSet {
  return config;
}

function matchSoundScripts(moduleId: string) {
  if (moduleId.includes("hiragana")) {
    return createLinks({
      examSectionIds: ["hiragana", "special-kana", "reading"],
      vocabularyCategoryIds: ["greetings", "food", "places"],
    });
  }

  if (moduleId.includes("katakana")) {
    return createLinks({
      examSectionIds: ["katakana", "special-kana", "reading"],
      vocabularyCategoryIds: ["countries", "drinks", "transportation", "travel-words"],
    });
  }

  if (moduleId.includes("kanji")) {
    return createLinks({
      examSectionIds: ["kanji", "reading"],
      kanjiGroupIds: allKanjiIds(),
      vocabularyCategoryIds: ["numbers", "places", "basic-verbs"],
    });
  }
}

function matchAssessment(moduleId: string) {
  if (!hasAnyKeyword(moduleId, ["exam", "review"])) {
    return;
  }

  return createLinks({
    examSectionIds: allExamIds(),
    kanjiGroupIds: allKanjiIds(),
    vocabularyCategoryIds: allVocabIds(),
  });
}

function matchPracticalTopics(moduleId: string) {
  if (hasAnyKeyword(moduleId, ["number", "money", "time"])) {
    return createLinks({
      examSectionIds: ["numbers", "listening"],
      kanjiGroupIds: ["kanji-numbers-money", "kanji-time-nature"],
      vocabularyCategoryIds: ["numbers", "money", "time-expressions", "weekdays", "months-dates"],
    });
  }

  if (hasAnyKeyword(moduleId, ["food", "cafe", "restaurant"])) {
    return createLinks({
      examSectionIds: ["vocabulary", "speaking"],
      vocabularyCategoryIds: ["food", "drinks", "shopping-words"],
    });
  }

  if (moduleId.includes("shop")) {
    return createLinks({
      examSectionIds: ["numbers", "speaking", "vocabulary"],
      vocabularyCategoryIds: ["shopping-words", "money", "everyday-objects"],
    });
  }

  if (moduleId.includes("routine")) {
    return createLinks({
      examSectionIds: ["speaking", "grammar"],
      vocabularyCategoryIds: ["time-expressions", "basic-verbs", "house-words"],
    });
  }
}

function matchGrammarTopics(moduleId: string) {
  if (hasAnyKeyword(moduleId, ["question", "sentence"])) {
    return createLinks({
      examSectionIds: ["particles", "grammar", "speaking"],
      vocabularyCategoryIds: ["question-words", "basic-expressions", "people"],
    });
  }

  if (moduleId.includes("particle")) {
    return createLinks({
      examSectionIds: ["particles", "grammar"],
      vocabularyCategoryIds: ["basic-expressions", "direction-words", "places"],
    });
  }

  if (hasAnyKeyword(moduleId, ["verb", "adjective"])) {
    return createLinks({
      examSectionIds: ["verbs-adjectives", "grammar"],
      vocabularyCategoryIds: ["basic-verbs", "basic-adjectives", "common-adverbs"],
    });
  }

  if (moduleId.includes("counter")) {
    return createLinks({
      examSectionIds: ["counters", "numbers"],
      vocabularyCategoryIds: ["numbers", "money", "people", "everyday-objects"],
    });
  }
}

function matchConversationTopics(moduleId: string) {
  if (hasAnyKeyword(moduleId, ["greeting", "survival"])) {
    return createLinks({
      examSectionIds: ["vocabulary", "speaking"],
      vocabularyCategoryIds: ["greetings", "basic-expressions", "question-words"],
    });
  }

  if (moduleId.includes("direction")) {
    return createLinks({
      examSectionIds: ["speaking", "listening"],
      kanjiGroupIds: ["kanji-directions-places"],
      vocabularyCategoryIds: ["direction-words", "places", "travel-words"],
    });
  }

  if (moduleId.includes("listen")) {
    return createLinks({
      examSectionIds: ["listening", "reading"],
      vocabularyCategoryIds: ["basic-expressions", "numbers", "greetings"],
    });
  }

  if (moduleId.includes("read")) {
    return createLinks({
      examSectionIds: ["reading", "kanji"],
      kanjiGroupIds: ["kanji-objects-environment", "kanji-people-relations"],
      vocabularyCategoryIds: ["greetings", "travel-words", "question-words"],
    });
  }
}

function matchPeopleAndPlaces(moduleId: string) {
  if (hasAnyKeyword(moduleId, ["people", "family"])) {
    return createLinks({
      examSectionIds: ["vocabulary", "speaking"],
      kanjiGroupIds: ["kanji-people-relations"],
      vocabularyCategoryIds: ["people", "family", "jobs"],
    });
  }

  if (hasAnyKeyword(moduleId, ["place", "object"])) {
    return createLinks({
      examSectionIds: ["vocabulary", "reading"],
      kanjiGroupIds: ["kanji-directions-places", "kanji-objects-environment"],
      vocabularyCategoryIds: ["places", "buildings", "everyday-objects"],
    });
  }
}

function defaultLinks() {
  return createLinks({
    examSectionIds: defaultExam,
    vocabularyCategoryIds: ["greetings", "numbers", "basic-expressions"],
  });
}

export function getJapaneseResourceLinks(moduleId: string): ResourceLinkSet {
  return (
    matchSoundScripts(moduleId) ??
    matchAssessment(moduleId) ??
    matchPracticalTopics(moduleId) ??
    matchGrammarTopics(moduleId) ??
    matchConversationTopics(moduleId) ??
    matchPeopleAndPlaces(moduleId) ??
    defaultLinks()
  );
}
