import { type CompletionState, type LanguageCourseDefinition } from "@/lib/course-definitions";

type StoredModuleProgress = {
  completedAt: string | null;
  currentTurn: number;
  lastTranscript: string;
  sessionsStarted: number;
  state: CompletionState;
};

export type StoredCourseProgress = {
  modules: Record<string, StoredModuleProgress>;
  version: 1;
};

const STORAGE_VERSION = 1;

function createModuleProgress() {
  return {
    completedAt: null,
    currentTurn: 0,
    lastTranscript: "",
    sessionsStarted: 0,
    state: "not_started",
  } satisfies StoredModuleProgress;
}

export function createDefaultCourseProgress(course: LanguageCourseDefinition) {
  return {
    version: STORAGE_VERSION,
    modules: Object.fromEntries(
      course.framework.levels.flatMap((level) =>
        level.modules.map((module) => [module.id, createModuleProgress()]),
      ),
    ),
  } satisfies StoredCourseProgress;
}

export function getCourseProgressKey(userId: string, slug: string) {
  return `ai-voice-tutor.progress.${userId}.${slug}`;
}

export function loadCourseProgress(
  course: LanguageCourseDefinition,
  storageValue: string | null,
) {
  const fallback = createDefaultCourseProgress(course);

  if (!storageValue) {
    return fallback;
  }

  try {
    const parsed = JSON.parse(storageValue) as StoredCourseProgress;
    if (parsed.version !== STORAGE_VERSION || !parsed.modules) {
      return fallback;
    }

    return {
      ...fallback,
      modules: {
        ...fallback.modules,
        ...parsed.modules,
      },
    };
  } catch {
    return fallback;
  }
}

export function saveCourseProgress(
  key: string,
  progress: StoredCourseProgress,
) {
  window.localStorage.setItem(key, JSON.stringify(progress));
}

export function countCompletedModules(progress: StoredCourseProgress) {
  return Object.values(progress.modules).filter(
    (module) => module.state === "completed",
  ).length;
}
