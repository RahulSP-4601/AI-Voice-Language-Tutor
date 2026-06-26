import { createLevel, createModule, createPlaceholderLevel } from "@/lib/course-builders";
import { japaneseCourseResources, getJapaneseResourceLinks } from "@/lib/japanese-course-resources";
import { type LanguageCourseDefinition } from "@/lib/course-types";
import { japaneseN5PhaseApplication } from "@/lib/japanese-n5-phase-application";
import { japaneseN5PhaseHiragana } from "@/lib/japanese-n5-phase-hiragana";
import { japaneseN5PhaseKatakana } from "@/lib/japanese-n5-phase-katakana";
import { japaneseN5PhaseLanguage } from "@/lib/japanese-n5-phase-language";
import { japaneseN5PhaseZero } from "@/lib/japanese-n5-phase-zero";

function createJapaneseN5Modules() {
  return [
    ...japaneseN5PhaseZero,
    ...japaneseN5PhaseHiragana,
    ...japaneseN5PhaseKatakana,
    ...japaneseN5PhaseLanguage,
    ...japaneseN5PhaseApplication,
  ].map((seed) => {
    const courseModule = createModule(seed);
    return {
      ...courseModule,
      resourceLinks:
        courseModule.resourceLinks ?? getJapaneseResourceLinks(courseModule.id),
    };
  });
}

export const japaneseCourse: LanguageCourseDefinition = {
  slug: "japanese",
  name: "Japanese",
  nativeSupportLabel: "Native-language support active for beginner correction",
  heroSummary:
    "Learn Japanese from absolute zero through a full lesson-dense JLPT N5 journey taught in English with romaji support, kana, grammar, roleplay, and a free final certificate.",
  lessonDuration: "15-20 minute voice lesson",
  resources: japaneseCourseResources,
  framework: {
    name: "JLPT",
    levels: [
      createLevel({
        id: "jp-n5",
        officialLabel: "N5",
        productLabel: "Basic 1",
        objective:
          "Build complete beginner-safe Japanese from romaji and sounds to kana, grammar, roleplay, and the final N5 certificate challenge.",
        examTitle: "JLPT N5 complete certificate exam",
        passRequirement:
          "Complete every N5 mission and clear the final guided voice exam to unlock the course certificate.",
        certificateTitle: "JLPT N5 completion certificate",
        certificateSummary:
          "Issued after the learner completes the full N5 journey and passes the final guided certificate exam.",
        modules: createJapaneseN5Modules(),
      }),
      createPlaceholderLevel({
        id: "jp-n4",
        officialLabel: "N4",
        productLabel: "Basic 2",
        objective: "Expand everyday communication with longer phrases and more flexible listening.",
      }),
      createPlaceholderLevel({
        id: "jp-n3",
        officialLabel: "N3",
        productLabel: "Intermediate 1",
        objective: "Handle practical real-world conversation with stronger comprehension.",
      }),
      createPlaceholderLevel({
        id: "jp-n2",
        officialLabel: "N2",
        productLabel: "Advanced 1",
        objective: "Build advanced fluency for study, work, and nuanced response control.",
      }),
      createPlaceholderLevel({
        id: "jp-n1",
        officialLabel: "N1",
        productLabel: "Advanced 2",
        objective: "Reach elite-level comprehension and polished spontaneous speaking.",
      }),
    ],
  },
};
