"use client";

import { type Dispatch, type RefObject, type SetStateAction, useEffect, useRef, useState } from "react";
import {
  type CourseSlug,
  type LanguageCourseDefinition,
} from "@/lib/course-definitions";
import {
  getCourseProgressKey,
  loadCourseProgress,
  saveCourseProgress,
  type StoredCourseProgress,
} from "@/lib/course-progress";
import {
  loadRemoteCourseProgress,
  syncRemoteCourseProgress,
} from "@/lib/course-progress-remote";
import { getGuestId, resolveAccountProfile } from "@/lib/user-session";

type CourseProgressState = {
  key: string | null;
  progress: StoredCourseProgress | null;
  ready: boolean;
  userId: string;
};

type ProgressUpdater =
  | StoredCourseProgress
  | null
  | ((current: StoredCourseProgress | null) => StoredCourseProgress | null);

function createInitialProgressState() {
  return {
    key: null,
    progress: null,
    ready: false,
    userId: getGuestId(),
  } satisfies CourseProgressState;
}

function getCurrentCourseKey(
  slug: CourseSlug,
  course: LanguageCourseDefinition | null,
) {
  return course ? `${slug}:${course.slug}` : null;
}

function canPersistProgress(state: CourseProgressState, currentKey: string | null) {
  return !!state.progress && state.ready && !!currentKey && state.key === currentKey;
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

function useProgressLoader(
  course: LanguageCourseDefinition | null,
  previousProgressRef: RefObject<StoredCourseProgress | null>,
  setState: Dispatch<SetStateAction<CourseProgressState>>,
  slug: CourseSlug,
) {
  useEffect(() => {
    if (!course) {
      return;
    }

    let active = true;
    const activeCourse = course;

    async function bootProgress() {
      const nextUserId = await resolveUserId();
      if (!active) {
        return;
      }

      const storageKey = getCourseProgressKey(nextUserId, slug);
      const local = loadCourseProgress(
        activeCourse,
        window.localStorage.getItem(storageKey),
      );
      const remote = nextUserId === getGuestId()
        ? null
        : await loadRemoteCourseProgress(activeCourse, slug).catch(() => null);
      const stored = remote?.progress ?? local;
      previousProgressRef.current = stored;
      setState({
        key: `${slug}:${activeCourse.slug}`,
        progress: stored,
        ready: true,
        userId: remote?.userId ?? nextUserId,
      });
    }

    bootProgress();
    return () => {
      active = false;
    };
  }, [course, previousProgressRef, setState, slug]);
}

function getVisibleProgress(state: CourseProgressState, currentKey: string | null) {
  return {
    progress: state.key === currentKey ? state.progress : null,
    ready: state.ready && !!state.progress && state.key === currentKey,
  };
}

function useLocalProgressPersistence(
  currentKey: string | null,
  slug: CourseSlug,
  state: CourseProgressState,
) {
  useEffect(() => {
    if (!canPersistProgress(state, currentKey) || !state.progress) {
      return;
    }

    saveCourseProgress(getCourseProgressKey(state.userId, slug), state.progress);
  }, [currentKey, slug, state]);
}

function useRemoteProgressPersistence(
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
    if (!progress || !previous) {
      previousProgressRef.current = progress;
      return;
    }

    const timer = window.setTimeout(() => {
      void syncRemoteCourseProgress({
        next: progress,
        previous,
        slug,
        userId: state.userId,
      })
        .catch((error) => {
          console.error("Unable to sync course progress.", error);
        })
        .finally(() => {
          previousProgressRef.current = progress;
        });
    }, 400);

    return () => window.clearTimeout(timer);
  }, [currentKey, previousProgressRef, slug, state]);
}

export function useCourseProgress(
  slug: CourseSlug,
  course: LanguageCourseDefinition | null,
) {
  const previousProgressRef = useRef<StoredCourseProgress | null>(null);
  const [state, setState] = useState<CourseProgressState>(createInitialProgressState);
  const currentKey = getCurrentCourseKey(slug, course);

  useProgressLoader(course, previousProgressRef, setState, slug);
  useLocalProgressPersistence(currentKey, slug, state);
  useRemoteProgressPersistence(currentKey, previousProgressRef, slug, state);

  const visible = getVisibleProgress(state, currentKey);
  return {
    progress: visible.progress,
    ready: visible.ready,
    setProgress: (updater: ProgressUpdater) => applyProgressUpdate(setState, updater),
  };
}

async function resolveUserId() {
  const profile = await resolveAccountProfile();
  return profile.userId ?? getGuestId();
}
