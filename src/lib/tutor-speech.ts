import { type CourseSlug } from "@/lib/course-definitions";

const TUTOR_SPEECH_MODELS: Record<CourseSlug, string> = {
  english: "aura-2-thalia-en",
  french: "aura-2-agathe-fr",
  german: "aura-2-viktoria-de",
  japanese: "aura-2-izanami-ja",
  spanish: "aura-2-celeste-es",
};

export function getTutorSpeechModel(slug: CourseSlug) {
  return TUTOR_SPEECH_MODELS[slug];
}
