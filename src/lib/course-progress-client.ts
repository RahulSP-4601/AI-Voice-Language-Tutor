"use client";

import { type Dispatch, type RefObject, type SetStateAction } from "react";
import { type CourseSlug, type LanguageCourseDefinition } from "@/lib/course-definitions";
import {
  createDefaultCourseProgress,
  type StoredCourseProgress,
  type StoredPracticeItemProgress,
} from "@/lib/course-progress";
import {
  hasImportantRemoteProgressChanges,
  hasRemoteProgressChanges,
  loadRemoteCourseProgress,
  syncRemoteCourseProgress,
} from "@/lib/course-progress-remote";
import { getGuestId } from "@/lib/user-session";

export const IMPORTANT_SYNC_DELAY_MS = 1200;
export const MODULE_HYDRATION_RETRY_DELAY_MS = 3000;
export const TRANSIENT_SYNC_DELAY_MS = 5000;

export type CourseProgressState = {
  key: string | null;
  progress: StoredCourseProgress | null;
  ready: boolean;
  userId: string;
};

export type CourseProgressOptions = {
  activeModuleId?: string | null;
  practiceScope?: "active-module" | "course";
};

export function getCurrentCourseKey(
  slug: CourseSlug,
  course: LanguageCourseDefinition | null,
) {
  return course ? `${slug}:${course.slug}` : null;
}

export function canPersistProgress(state: CourseProgressState, currentKey: string | null) {
  return !!state.progress && state.ready && !!currentKey && state.key === currentKey;
}

function getScopedPracticeModuleId(
  practiceScope: CourseProgressOptions["practiceScope"],
  activeModuleId: string | null | undefined,
) {
  return practiceScope === "active-module" ? activeModuleId ?? null : undefined;
}

function getLoadedPracticeModules(
  practiceScope: CourseProgressOptions["practiceScope"],
  activeModuleId: string | null | undefined,
  remoteLoaded: boolean,
) {
  return new Set(
    practiceScope === "active-module" && activeModuleId && remoteLoaded ? [activeModuleId] : [],
  );
}

export async function resolveBootProgress(input: {
  activeCourse: LanguageCourseDefinition;
  activeModuleId: string | null | undefined;
  nextUserId: string;
  practiceScope: CourseProgressOptions["practiceScope"];
  slug: CourseSlug;
}) {
  const fallback = createDefaultCourseProgress(input.activeCourse);
  const remote = input.nextUserId === getGuestId()
    ? null
    : await loadRemoteCourseProgress(input.activeCourse, input.slug, {
      practiceModuleId: getScopedPracticeModuleId(input.practiceScope, input.activeModuleId),
    }).catch(() => null);

  return {
    progress: remote?.progress ?? fallback,
    userId: remote?.userId ?? input.nextUserId,
    loadedPracticeModules: getLoadedPracticeModules(
      input.practiceScope,
      input.activeModuleId,
      Boolean(remote),
    ),
  };
}

export function shouldSkipProgressBoot(input: {
  active: boolean;
  currentUserId: string;
  nextKey: string;
  nextUserId: string;
  stateKey: string | null;
}) {
  return !input.active || (input.stateKey === input.nextKey && input.currentUserId === input.nextUserId);
}

export function applyBootProgress(input: {
  loadedPracticeModules: Set<string>;
  loadedPracticeModulesRef: RefObject<Set<string>>;
  nextKey: string;
  previousProgressRef: RefObject<StoredCourseProgress | null>;
  progress: StoredCourseProgress;
  setState: Dispatch<SetStateAction<CourseProgressState>>;
  userId: string;
}) {
  input.loadedPracticeModulesRef.current = input.loadedPracticeModules;
  input.previousProgressRef.current = input.progress;
  input.setState({
    key: input.nextKey,
    progress: input.progress,
    ready: true,
    userId: input.userId,
  });
}

export function syncDelayForProgress(previous: StoredCourseProgress, progress: StoredCourseProgress) {
  return hasImportantRemoteProgressChanges(previous, progress)
    ? IMPORTANT_SYNC_DELAY_MS
    : TRANSIENT_SYNC_DELAY_MS;
}

export function flushProgressState(input: {
  currentKey: string | null;
  latestState: CourseProgressState;
  previousProgressRef: RefObject<StoredCourseProgress | null>;
  slug: CourseSlug;
}) {
  if (!canPersistProgress(input.latestState, input.currentKey)) {
    return;
  }

  const previous = input.previousProgressRef.current;
  const progress = input.latestState.progress;
  if (!previous || !progress || !hasRemoteProgressChanges(previous, progress)) {
    return;
  }

  void syncRemoteCourseProgress({
    next: progress,
    previous,
    slug: input.slug,
    userId: input.latestState.userId,
  })
    .catch((error) => {
      console.error("Unable to flush course progress.", error);
    })
    .finally(() => {
      input.previousProgressRef.current = progress;
    });
}

export function mergeHydratedModuleProgress(input: {
  current: CourseProgressState;
  currentKey: string | null;
  moduleId: string;
  practiceItems: Record<string, StoredPracticeItemProgress>;
  previousProgressRef: RefObject<StoredCourseProgress | null>;
}) {
  if (!input.current.progress || input.current.key !== input.currentKey) {
    return input.current;
  }

  const mergedPracticeItems = {
    ...input.practiceItems,
    ...input.current.progress.modules[input.moduleId].practiceItems,
  };
  const nextProgress = {
    ...input.current.progress,
    modules: {
      ...input.current.progress.modules,
      [input.moduleId]: {
        ...input.current.progress.modules[input.moduleId],
        practiceItems: mergedPracticeItems,
      },
    },
  };
  input.previousProgressRef.current = input.previousProgressRef.current
    ? {
        ...input.previousProgressRef.current,
        modules: {
          ...input.previousProgressRef.current.modules,
          [input.moduleId]: {
            ...input.previousProgressRef.current.modules[input.moduleId],
            practiceItems: input.practiceItems,
          },
        },
      }
    : input.previousProgressRef.current;

  return {
    ...input.current,
    progress: nextProgress,
  };
}

export function scheduleModuleRetry(input: {
  fallbackPracticeModulesRef: RefObject<Set<string>>;
  moduleId: string;
  retryModuleHydration: () => void;
  retryTimersRef: RefObject<Map<string, number>>;
}) {
  input.fallbackPracticeModulesRef.current.add(input.moduleId);
  if (input.retryTimersRef.current.has(input.moduleId)) {
    return;
  }

  const timerId = window.setTimeout(() => {
    input.fallbackPracticeModulesRef.current.delete(input.moduleId);
    input.retryTimersRef.current.delete(input.moduleId);
    input.retryModuleHydration();
  }, MODULE_HYDRATION_RETRY_DELAY_MS);
  input.retryTimersRef.current.set(input.moduleId, timerId);
}

export function clearModuleRetryTimer(
  retryTimersRef: RefObject<Map<string, number>>,
  moduleId: string,
) {
  const timerId = retryTimersRef.current.get(moduleId);
  if (!timerId) {
    return;
  }

  window.clearTimeout(timerId);
  retryTimersRef.current.delete(moduleId);
}

export function cloneProgressState(progress: StoredCourseProgress | null) {
  return progress
    ? {
        ...progress,
        modules: {
          ...progress.modules,
        },
      }
    : progress;
}

export function isActiveModuleHydrationPending(input: {
  activeModuleId?: string | null;
  currentKey: string | null;
  fallbackPracticeModulesRef: RefObject<Set<string>>;
  loadedPracticeModulesRef: RefObject<Set<string>>;
  state: CourseProgressState;
}) {
  return Boolean(
    input.activeModuleId &&
      input.state.userId !== getGuestId() &&
      canPersistProgress(input.state, input.currentKey) &&
      !input.fallbackPracticeModulesRef.current.has(input.activeModuleId) &&
      !input.loadedPracticeModulesRef.current.has(input.activeModuleId),
  );
}
