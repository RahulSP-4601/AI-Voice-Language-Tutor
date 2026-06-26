import { type CompletionState, type LanguageCourseDefinition } from "@/lib/course-definitions";

export type StoredPracticeItemProgress = {
  done: boolean;
  lastScore: number | null;
  lastTranscript: string;
  practicedAt: string | null;
};

export type StoredModuleProgress = {
  completedAt: string | null;
  currentTurn: number;
  lastTranscript: string;
  practiceItems: Record<string, StoredPracticeItemProgress>;
  sessionsStarted: number;
  state: CompletionState;
};

export type StoredCourseProgress = {
  modules: Record<string, StoredModuleProgress>;
  version: 2;
};

const STORAGE_VERSION = 2;

function createPracticeItemProgress() {
  return {
    done: false,
    lastScore: null,
    lastTranscript: "",
    practicedAt: null,
  } satisfies StoredPracticeItemProgress;
}

function createModuleProgress() {
  return {
    completedAt: null,
    currentTurn: 0,
    lastTranscript: "",
    practiceItems: {},
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
    const parsed = JSON.parse(storageValue) as {
      modules?: Record<string, Partial<StoredModuleProgress>>;
      version?: number;
    };
    if (!parsed.modules) {
      return fallback;
    }

    return {
      ...fallback,
      modules: mergeStoredModules(fallback.modules, parsed.modules),
    };
  } catch {
    return fallback;
  }
}

function mergeStoredModules(
  fallback: Record<string, StoredModuleProgress>,
  stored: Record<string, Partial<StoredModuleProgress>>,
) {
  return Object.fromEntries(
    Object.entries(fallback).map(([moduleId, fallbackModule]) => [
      moduleId,
      mergeModuleProgress(fallbackModule, stored[moduleId]),
    ]),
  );
}

function mergeModuleProgress(
  fallback: StoredModuleProgress,
  stored?: Partial<StoredModuleProgress>,
) {
  if (!stored) {
    return fallback;
  }

  return {
    ...fallback,
    ...stored,
    practiceItems: mergePracticeItems(stored.practiceItems),
  } satisfies StoredModuleProgress;
}

function mergePracticeItems(
  stored?: Record<string, Partial<StoredPracticeItemProgress>>,
) {
  if (!stored) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(stored).map(([itemId, value]) => [
      itemId,
      { ...createPracticeItemProgress(), ...value },
    ]),
  );
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
