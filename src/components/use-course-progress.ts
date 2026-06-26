"use client";

import { type Dispatch, type SetStateAction, useEffect, useState } from "react";
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
      const stored = loadCourseProgress(
        activeCourse,
        window.localStorage.getItem(storageKey),
      );
      setState({
        key: `${slug}:${activeCourse.slug}`,
        progress: stored,
        ready: true,
        userId: nextUserId,
      });
    }

    bootProgress();
    return () => {
      active = false;
    };
  }, [course, setState, slug]);
}

function getVisibleProgress(state: CourseProgressState, currentKey: string | null) {
  return {
    progress: state.key === currentKey ? state.progress : null,
    ready: state.ready && !!state.progress && state.key === currentKey,
  };
}

export function useCourseProgress(
  slug: CourseSlug,
  course: LanguageCourseDefinition | null,
) {
  const [state, setState] = useState<CourseProgressState>({
    key: null,
    progress: null,
    ready: false,
    userId: getGuestId(),
  });
  const currentKey = getCurrentCourseKey(slug, course);

  useProgressLoader(course, setState, slug);
  useEffect(() => {
    if (!canPersistProgress(state, currentKey)) {
      return;
    }

    const progress = state.progress;
    if (!progress) {
      return;
    }

    saveCourseProgress(getCourseProgressKey(state.userId, slug), progress);
  }, [currentKey, slug, state]);

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
