"use client";

import { type Dispatch, type RefObject, type SetStateAction, useEffect, useRef, useState } from "react";
import { type CourseSlug, type LanguageCourseDefinition } from "@/lib/course-definitions";
import { type StoredCourseProgress } from "@/lib/course-progress";
import {
  applyBootProgress,
  canPersistProgress,
  clearModuleRetryTimer,
  cloneProgressState,
  type CourseProgressOptions,
  type CourseProgressState,
  flushProgressState,
  getCurrentCourseKey,
  isActiveModuleHydrationPending,
  mergeHydratedModuleProgress,
  resolveBootProgress,
  scheduleModuleRetry,
  shouldSkipProgressBoot,
  syncDelayForProgress,
} from "@/lib/course-progress-client";
import {
  hasRemoteProgressChanges,
  loadRemoteModulePracticeItems,
  syncRemoteCourseProgress,
} from "@/lib/course-progress-remote";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";
import { getGuestId, resolveAccountProfile } from "@/lib/user-session";

type ProgressUpdater =
  | StoredCourseProgress
  | null
  | ((current: StoredCourseProgress | null) => StoredCourseProgress | null);

type ModuleHydrationInput = {
  activeModuleId?: string | null;
  currentKey: string | null;
  fallbackPracticeModulesRef: RefObject<Set<string>>;
  hydrationRetryNonce: number;
  loadedPracticeModulesRef: RefObject<Set<string>>;
  previousProgressRef: RefObject<StoredCourseProgress | null>;
  retryModuleHydration: () => void;
  retryTimersRef: RefObject<Map<string, number>>;
  setState: Dispatch<SetStateAction<CourseProgressState>>;
  slug: CourseSlug;
  state: CourseProgressState;
};

function createInitialProgressState() {
  return {
    key: null,
    progress: null,
    ready: false,
    userId: getGuestId(),
  } satisfies CourseProgressState;
}

function applyProgressUpdate(
  setState: Dispatch<SetStateAction<CourseProgressState>>,
  updater: ProgressUpdater,
) {
  setState((current) => ({
    ...current,
    progress:
      typeof updater === "function" ? updater(current.progress) : updater,
  }));
}

async function resolveUserId() {
  const profile = await resolveAccountProfile();
  return profile.userId ?? getGuestId();
}

async function bootCourseProgress(input: {
  active: () => boolean;
  activeModuleId: string | null | undefined;
  course: LanguageCourseDefinition;
  currentUserId: string;
  loadedPracticeModulesRef: RefObject<Set<string>>;
  practiceScope: CourseProgressOptions["practiceScope"];
  previousProgressRef: RefObject<StoredCourseProgress | null>;
  setState: Dispatch<SetStateAction<CourseProgressState>>;
  slug: CourseSlug;
  stateKey: string | null;
}) {
  const nextUserId = await resolveUserId();
  const nextKey = `${input.slug}:${input.course.slug}`;
  if (shouldSkipProgressBoot({
    active: input.active(),
    currentUserId: input.currentUserId,
    nextKey,
    nextUserId,
    stateKey: input.stateKey,
  })) {
    return;
  }

  const resolved = await resolveBootProgress({
    activeCourse: input.course,
    activeModuleId: input.activeModuleId,
    nextUserId,
    practiceScope: input.practiceScope,
    slug: input.slug,
  });
  if (!input.active()) {
    return;
  }

  applyBootProgress({
    loadedPracticeModules: resolved.loadedPracticeModules,
    loadedPracticeModulesRef: input.loadedPracticeModulesRef,
    nextKey,
    previousProgressRef: input.previousProgressRef,
    progress: resolved.progress,
    setState: input.setState,
    userId: resolved.userId,
  });
}

function useProgressLoader(input: {
  activeModuleId: string | null | undefined;
  authReloadNonce: number;
  course: LanguageCourseDefinition | null;
  currentUserId: string;
  loadedPracticeModulesRef: RefObject<Set<string>>;
  practiceScope: CourseProgressOptions["practiceScope"];
  previousProgressRef: RefObject<StoredCourseProgress | null>;
  setState: Dispatch<SetStateAction<CourseProgressState>>;
  slug: CourseSlug;
  stateKey: string | null;
}) {
  useEffect(() => {
    if (!input.course) {
      return;
    }

    let active = true;
    void bootCourseProgress({
      ...input,
      course: input.course,
      active: () => active,
    });
    return () => {
      active = false;
    };
  }, [input]);
}

function useAuthReloadSignal() {
  const [authReloadNonce, setAuthReloadNonce] = useState(0);

  useEffect(() => {
    if (!hasSupabaseEnv()) {
      return;
    }

    const supabase = getSupabaseBrowserClient();
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(() => {
      setAuthReloadNonce((value) => value + 1);
    });

    return () => subscription.unsubscribe();
  }, []);

  return authReloadNonce;
}

function getVisibleProgress(state: CourseProgressState, currentKey: string | null) {
  return {
    progress: state.key === currentKey ? state.progress : null,
    ready: state.ready && !!state.progress && state.key === currentKey,
  };
}

function useScheduledRemoteSync(
  currentKey: string | null,
  previousProgressRef: RefObject<StoredCourseProgress | null>,
  slug: CourseSlug,
  state: CourseProgressState,
) {
  useEffect(() => {
    if (!canPersistProgress(state, currentKey) || state.userId === getGuestId()) {
      return;
    }

    const progress = state.progress;
    const previous = previousProgressRef.current;
    if (!progress || !previous || !hasRemoteProgressChanges(previous, progress)) {
      if (!previous) {
        previousProgressRef.current = progress;
      }
      return;
    }

    const timer = window.setTimeout(() => {
      void syncRemoteCourseProgress({
        next: progress,
        previous,
        slug,
        userId: state.userId,
      }).finally(() => {
        previousProgressRef.current = progress;
      });
    }, syncDelayForProgress(previous, progress));

    return () => window.clearTimeout(timer);
  }, [currentKey, previousProgressRef, slug, state]);
}

function useVisibilityProgressFlush(
  currentKey: string | null,
  latestStateRef: RefObject<CourseProgressState>,
  previousProgressRef: RefObject<StoredCourseProgress | null>,
  slug: CourseSlug,
  userId: string,
) {
  useEffect(() => {
    if (userId === getGuestId()) {
      return;
    }

    function flushProgress() {
      flushProgressState({
        currentKey,
        latestState: latestStateRef.current,
        previousProgressRef,
        slug,
      });
    }

    function handleVisibilityChange() {
      if (document.visibilityState === "hidden") {
        flushProgress();
      }
    }

    window.addEventListener("pagehide", flushProgress);
    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => {
      window.removeEventListener("pagehide", flushProgress);
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [currentKey, latestStateRef, previousProgressRef, slug, userId]);
}

function useRemoteProgressPersistence(
  currentKey: string | null,
  previousProgressRef: RefObject<StoredCourseProgress | null>,
  slug: CourseSlug,
  state: CourseProgressState,
) {
  const latestStateRef = useRef(state);
  useEffect(() => {
    latestStateRef.current = state;
  }, [state]);

  useScheduledRemoteSync(currentKey, previousProgressRef, slug, state);
  useVisibilityProgressFlush(currentKey, latestStateRef, previousProgressRef, slug, state.userId);
}

function handleHydrationSuccess(input: {
  active: boolean;
  currentKey: string | null;
  fallbackPracticeModulesRef: RefObject<Set<string>>;
  loadedPracticeModulesRef: RefObject<Set<string>>;
  moduleId: string;
  practiceItems: Awaited<ReturnType<typeof loadRemoteModulePracticeItems>>;
  previousProgressRef: RefObject<StoredCourseProgress | null>;
  retryTimersRef: RefObject<Map<string, number>>;
  setState: Dispatch<SetStateAction<CourseProgressState>>;
}) {
  const practiceItems = input.practiceItems;
  if (!input.active || !practiceItems) {
    return;
  }

  input.fallbackPracticeModulesRef.current.delete(input.moduleId);
  input.loadedPracticeModulesRef.current.add(input.moduleId);
  clearModuleRetryTimer(input.retryTimersRef, input.moduleId);
  input.setState((current) =>
    mergeHydratedModuleProgress({
      current,
      currentKey: input.currentKey,
      moduleId: input.moduleId,
      practiceItems,
      previousProgressRef: input.previousProgressRef,
    }),
  );
}

function handleHydrationFailure(input: {
  active: boolean;
  currentKey: string | null;
  fallbackPracticeModulesRef: RefObject<Set<string>>;
  moduleId: string;
  retryModuleHydration: () => void;
  retryTimersRef: RefObject<Map<string, number>>;
  setState: Dispatch<SetStateAction<CourseProgressState>>;
}) {
  if (!input.active) {
    return;
  }

  scheduleModuleRetry({
    fallbackPracticeModulesRef: input.fallbackPracticeModulesRef,
    moduleId: input.moduleId,
    retryModuleHydration: input.retryModuleHydration,
    retryTimersRef: input.retryTimersRef,
  });
  input.setState((current) =>
    current.key === input.currentKey
      ? { ...current, progress: cloneProgressState(current.progress) }
      : current,
  );
}

function useActiveModuleHydration(input: ModuleHydrationInput) {
  const { activeModuleId, currentKey, hydrationRetryNonce, slug, state } = input;

  useEffect(() => {
    if (!activeModuleId || !isActiveModuleHydrationPending(input)) {
      return;
    }

    let active = true;
    void loadRemoteModulePracticeItems(slug, activeModuleId)
      .then((practiceItems) => {
        handleHydrationSuccess({
          active,
          currentKey,
          fallbackPracticeModulesRef: input.fallbackPracticeModulesRef,
          loadedPracticeModulesRef: input.loadedPracticeModulesRef,
          moduleId: activeModuleId,
          practiceItems,
          previousProgressRef: input.previousProgressRef,
          retryTimersRef: input.retryTimersRef,
          setState: input.setState,
        });
      })
      .catch(() => {
        handleHydrationFailure({
          active,
          currentKey,
          fallbackPracticeModulesRef: input.fallbackPracticeModulesRef,
          moduleId: activeModuleId,
          retryModuleHydration: input.retryModuleHydration,
          retryTimersRef: input.retryTimersRef,
          setState: input.setState,
        });
      });

    return () => {
      active = false;
    };
  }, [activeModuleId, currentKey, hydrationRetryNonce, input, slug, state]);
}

function useCourseProgressRefs() {
  return {
    fallbackPracticeModulesRef: useRef<Set<string>>(new Set()),
    loadedPracticeModulesRef: useRef<Set<string>>(new Set()),
    previousProgressRef: useRef<StoredCourseProgress | null>(null),
    retryTimersRef: useRef<Map<string, number>>(new Map()),
  };
}

function createModuleReadyChecker(
  practiceScope: CourseProgressOptions["practiceScope"],
  refs: ReturnType<typeof useCourseProgressRefs>,
) {
  return (moduleId?: string | null) =>
    practiceScope !== "active-module" ||
    !moduleId ||
    refs.fallbackPracticeModulesRef.current.has(moduleId) ||
    refs.loadedPracticeModulesRef.current.has(moduleId);
}

export function useCourseProgress(
  slug: CourseSlug,
  course: LanguageCourseDefinition | null,
  options?: CourseProgressOptions,
) {
  const practiceScope = options?.practiceScope ?? "course";
  const activeModuleId = options?.activeModuleId ?? null;
  const refs = useCourseProgressRefs();
  const [state, setState] = useState<CourseProgressState>(createInitialProgressState);
  const [hydrationRetryNonce, setHydrationRetryNonce] = useState(0);
  const authReloadNonce = useAuthReloadSignal();
  const currentKey = getCurrentCourseKey(slug, course);

  useProgressLoader({
    activeModuleId,
    authReloadNonce,
    course,
    currentUserId: state.userId,
    loadedPracticeModulesRef: refs.loadedPracticeModulesRef,
    practiceScope,
    previousProgressRef: refs.previousProgressRef,
    setState,
    slug,
    stateKey: state.key,
  });
  useRemoteProgressPersistence(currentKey, refs.previousProgressRef, slug, state);
  useActiveModuleHydration({
    activeModuleId: practiceScope === "active-module" ? activeModuleId : null,
    currentKey,
    fallbackPracticeModulesRef: refs.fallbackPracticeModulesRef,
    hydrationRetryNonce,
    loadedPracticeModulesRef: refs.loadedPracticeModulesRef,
    previousProgressRef: refs.previousProgressRef,
    retryModuleHydration: () => setHydrationRetryNonce((value) => value + 1),
    retryTimersRef: refs.retryTimersRef,
    setState,
    slug,
    state,
  });

  const visible = getVisibleProgress(state, currentKey);
  const isModuleReady = createModuleReadyChecker(practiceScope, refs);
  return {
    isModuleReady,
    progress: visible.progress,
    ready: visible.ready,
    setProgress: (updater: ProgressUpdater) => applyProgressUpdate(setState, updater),
  };
}
