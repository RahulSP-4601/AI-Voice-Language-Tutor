import { type CourseSlug } from "@/lib/course-definitions";

type TutorSpeechVoiceConfig = {
  backupModel: string | null;
  primaryModel: string;
};

const TUTOR_SPEECH_MODELS: Record<CourseSlug, TutorSpeechVoiceConfig> = {
  english: {
    backupModel: null,
    primaryModel: "aura-2-thalia-en",
  },
  french: {
    backupModel: null,
    primaryModel: "aura-2-agathe-fr",
  },
  german: {
    backupModel: null,
    primaryModel: "aura-2-viktoria-de",
  },
  japanese: {
    backupModel: null,
    primaryModel: "aura-2-izanami-ja",
  },
  spanish: {
    backupModel: null,
    primaryModel: "aura-2-celeste-es",
  },
};

function readSpeechModelOverride(key: string) {
  const value = process.env[key];
  return value && value.trim() ? value.trim() : null;
}

export function getTutorSpeechModels(slug: CourseSlug) {
  const defaults = TUTOR_SPEECH_MODELS[slug];
  const envPrefix = `DEEPGRAM_TTS_${slug.toUpperCase()}`;

  return {
    backupModel:
      readSpeechModelOverride(`${envPrefix}_BACKUP_MODEL`) ?? defaults.backupModel,
    primaryModel:
      readSpeechModelOverride(`${envPrefix}_PRIMARY_MODEL`) ?? defaults.primaryModel,
  } satisfies TutorSpeechVoiceConfig;
}
