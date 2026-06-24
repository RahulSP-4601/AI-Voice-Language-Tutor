"use client";

import { useEffect, useState } from "react";
import { type CourseSlug, courseDefinitions } from "@/lib/course-definitions";
import {
  createDefaultCourseProgress,
  getCourseProgressKey,
  loadCourseProgress,
  saveCourseProgress,
  type StoredCourseProgress,
} from "@/lib/course-progress";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

function getGuestId() {
  return "guest-user";
}

export function useCourseProgress(slug: CourseSlug) {
  const course = courseDefinitions[slug];
  const [ready, setReady] = useState(false);
  const [userId, setUserId] = useState(getGuestId());
  const [progress, setProgress] = useState<StoredCourseProgress>(
    createDefaultCourseProgress(course),
  );

  useEffect(() => {
    let active = true;

    async function bootProgress() {
      const nextUserId = await resolveUserId();
      if (!active) {
        return;
      }

      const storageKey = getCourseProgressKey(nextUserId, slug);
      const stored = loadCourseProgress(
        course,
        window.localStorage.getItem(storageKey),
      );
      setUserId(nextUserId);
      setProgress(stored);
      setReady(true);
    }

    bootProgress();
    return () => {
      active = false;
    };
  }, [course, slug]);

  useEffect(() => {
    if (!ready) {
      return;
    }

    saveCourseProgress(getCourseProgressKey(userId, slug), progress);
  }, [progress, ready, slug, userId]);

  return { progress, ready, setProgress };
}

async function resolveUserId() {
  if (!hasSupabaseEnv()) {
    return getGuestId();
  }

  const supabase = getSupabaseBrowserClient();
  const { data } = await supabase.auth.getUser();
  return data.user?.id ?? getGuestId();
}
