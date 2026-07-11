import { type CourseLesson, type CourseSlug } from "@/lib/course-definitions";
import { kanaToRomaji } from "@/lib/pronunciation-hint";

function hasJapaneseCharacters(value: string) {
  return /[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff々]/u.test(value);
}

function normalizeJapaneseRomaji(value: string) {
  const source = hasJapaneseCharacters(value) ? kanaToRomaji(value) : value;
  return source
    .toLowerCase()
    .normalize("NFKC")
    .replace(/ou/g, "o")
    .replace(/oo/g, "o")
    .replace(/uu/g, "u")
    .replace(/aa/g, "a")
    .replace(/ee/g, "e")
    .replace(/ei/g, "e")
    .replace(/wo/g, "o")
    .replace(/fu/g, "hu")
    .replace(/tsu/g, "tu")
    .replace(/shi/g, "si")
    .replace(/chi/g, "ti")
    .replace(/ji/g, "zi")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function joinJapanesePhrases(phrases: string[], demoPhrase: string) {
  if (phrases.length <= 1) {
    return phrases[0] ?? demoPhrase;
  }

  if (/[.!?]/.test(demoPhrase)) {
    return phrases.join("。 ");
  }

  if (/[\/]/.test(demoPhrase)) {
    return phrases.join(" / ");
  }

  return phrases.join("、 ");
}

export function resolveLessonSpeechText(
  lesson: Pick<CourseLesson, "acceptableResponses" | "demoPhrase">,
  slug: CourseSlug,
) {
  if (slug !== "japanese" || hasJapaneseCharacters(lesson.demoPhrase)) {
    return lesson.demoPhrase;
  }

  const japaneseResponses = Array.from(
    new Set(lesson.acceptableResponses.filter(hasJapaneseCharacters)),
  );
  if (!japaneseResponses.length) {
    return lesson.demoPhrase;
  }

  const demoKey = normalizeJapaneseRomaji(lesson.demoPhrase);
  const matched = japaneseResponses.filter((response) => {
    const responseKey = normalizeJapaneseRomaji(response);
    return Boolean(responseKey) && demoKey.includes(responseKey);
  });

  if (matched.length) {
    return joinJapanesePhrases(matched, lesson.demoPhrase);
  }

  if (japaneseResponses.length === 1) {
    return japaneseResponses[0];
  }

  return lesson.demoPhrase;
}
