"use client";

import { type SupabaseClient } from "@supabase/supabase-js";
import {
  createDefaultCourseProgress,
  type StoredCourseProgress,
  type StoredModuleProgress,
  type StoredPracticeItemProgress,
} from "@/lib/course-progress";
import { type CourseSlug, type LanguageCourseDefinition } from "@/lib/course-definitions";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";

type ModuleRow = {
  completed_at: null | string;
  current_turn: number;
  last_transcript: string;
  module_id: string;
  sessions_started: number;
  state: StoredModuleProgress["state"];
};

type PracticeItemRow = {
  accuracy_score: null | number;
  coaching_feedback: string;
  done: boolean;
  fluency_score: null | number;
  item_id: string;
  last_score: null | number;
  last_transcript: string;
  module_id: string;
  practiced_at: null | string;
  pronunciation_score: null | number;
};

function getBrowserSupabase() {
  return getSupabaseBrowserClient();
}

function buildStoredPracticeItem(row: PracticeItemRow) {
  return {
    accuracyScore: row.accuracy_score,
    coachingFeedback: row.coaching_feedback,
    done: row.done,
    fluencyScore: row.fluency_score,
    lastScore: row.last_score,
    lastTranscript: row.last_transcript,
    practicedAt: row.practiced_at,
    pronunciationScore: row.pronunciation_score,
  } satisfies StoredPracticeItemProgress;
}

function applyModuleRows(progress: StoredCourseProgress, rows: ModuleRow[]) {
  rows.forEach((row) => {
    const current = progress.modules[row.module_id];
    if (!current) return;
    progress.modules[row.module_id] = {
      ...current,
      completedAt: row.completed_at,
      currentTurn: row.current_turn,
      lastTranscript: row.last_transcript,
      sessionsStarted: row.sessions_started,
      state: row.state,
    };
  });
}

function applyPracticeRows(progress: StoredCourseProgress, rows: PracticeItemRow[]) {
  rows.forEach((row) => {
    const current = progress.modules[row.module_id];
    if (!current) return;
    current.practiceItems[row.item_id] = buildStoredPracticeItem(row);
  });
}

async function fetchModuleRows(supabase: SupabaseClient, slug: CourseSlug) {
  const { data, error } = await supabase
    .from("user_module_progress")
    .select("module_id, state, current_turn, last_transcript, sessions_started, completed_at")
    .eq("language_slug", slug);

  if (error) throw error;
  return (data ?? []) as ModuleRow[];
}

async function fetchPracticeRows(supabase: SupabaseClient, slug: CourseSlug) {
  const { data, error } = await supabase
    .from("user_practice_item_progress")
    .select(
      "module_id, item_id, done, last_score, last_transcript, pronunciation_score, accuracy_score, fluency_score, coaching_feedback, practiced_at",
    )
    .eq("language_slug", slug);

  if (error) throw error;
  return (data ?? []) as PracticeItemRow[];
}

export async function loadRemoteCourseProgress(
  course: LanguageCourseDefinition,
  slug: CourseSlug,
) {
  const supabase = getBrowserSupabase();
  const [{ data: authData }, moduleRows, practiceRows] = await Promise.all([
    supabase.auth.getUser(),
    fetchModuleRows(supabase, slug),
    fetchPracticeRows(supabase, slug),
  ]);
  const userId = authData.user?.id ?? null;
  if (!userId) {
    return null;
  }

  const progress = createDefaultCourseProgress(course);
  applyModuleRows(progress, moduleRows);
  applyPracticeRows(progress, practiceRows);
  return { progress, userId };
}

function samePracticeItem(
  left?: StoredPracticeItemProgress,
  right?: StoredPracticeItemProgress,
) {
  return JSON.stringify(left ?? null) === JSON.stringify(right ?? null);
}

function sameModule(left?: StoredModuleProgress, right?: StoredModuleProgress) {
  return JSON.stringify(left ?? null) === JSON.stringify(right ?? null);
}

function isTouchedModule(module: StoredModuleProgress) {
  return (
    module.state !== "not_started" ||
    module.currentTurn > 0 ||
    module.lastTranscript.trim().length > 0 ||
    module.sessionsStarted > 0 ||
    module.completedAt !== null
  );
}

function toModuleRow(userId: string, slug: CourseSlug, moduleId: string, module: StoredModuleProgress) {
  return {
    completed_at: module.completedAt,
    current_turn: module.currentTurn,
    language_slug: slug,
    last_transcript: module.lastTranscript,
    module_id: moduleId,
    sessions_started: module.sessionsStarted,
    state: module.state,
    updated_at: new Date().toISOString(),
    user_id: userId,
  };
}

function isTouchedPracticeItem(item: StoredPracticeItemProgress) {
  return (
    item.done ||
    typeof item.lastScore === "number" ||
    item.lastTranscript.trim().length > 0 ||
    item.practicedAt !== null
  );
}

function toPracticeRow(
  userId: string,
  slug: CourseSlug,
  moduleId: string,
  itemId: string,
  item: StoredPracticeItemProgress,
) {
  return {
    accuracy_score: item.accuracyScore,
    coaching_feedback: item.coachingFeedback,
    done: item.done,
    fluency_score: item.fluencyScore,
    item_id: itemId,
    language_slug: slug,
    last_score: item.lastScore,
    last_transcript: item.lastTranscript,
    module_id: moduleId,
    practiced_at: item.practicedAt,
    pronunciation_score: item.pronunciationScore,
    updated_at: new Date().toISOString(),
    user_id: userId,
  };
}

function changedModuleIds(previous: StoredCourseProgress, next: StoredCourseProgress) {
  return Object.keys(next.modules).filter((moduleId) =>
    !sameModule(previous.modules[moduleId], next.modules[moduleId]),
  );
}

function changedPracticeRows(
  userId: string,
  slug: CourseSlug,
  moduleId: string,
  previous: StoredModuleProgress,
  next: StoredModuleProgress,
) {
  const itemIds = new Set([
    ...Object.keys(previous.practiceItems),
    ...Object.keys(next.practiceItems),
  ]);

  return Array.from(itemIds)
    .filter((itemId) => !samePracticeItem(previous.practiceItems[itemId], next.practiceItems[itemId]))
    .map((itemId) => ({ itemId, item: next.practiceItems[itemId] }))
    .filter((entry): entry is { item: StoredPracticeItemProgress; itemId: string } => Boolean(entry.item))
    .filter((entry) => isTouchedPracticeItem(entry.item))
    .map((entry) => toPracticeRow(userId, slug, moduleId, entry.itemId, entry.item));
}

export async function syncRemoteCourseProgress(input: {
  next: StoredCourseProgress;
  previous: StoredCourseProgress;
  slug: CourseSlug;
  userId: string;
}) {
  const supabase = getBrowserSupabase();
  const moduleIds = changedModuleIds(input.previous, input.next);
  const moduleRows = moduleIds
    .map((moduleId) => ({ moduleId, module: input.next.modules[moduleId] }))
    .filter((entry) => isTouchedModule(entry.module))
    .map((entry) => toModuleRow(input.userId, input.slug, entry.moduleId, entry.module));

  const practiceRows = moduleIds.flatMap((moduleId) =>
    changedPracticeRows(
      input.userId,
      input.slug,
      moduleId,
      input.previous.modules[moduleId],
      input.next.modules[moduleId],
    ),
  );

  if (moduleRows.length > 0) {
    const { error } = await supabase
      .from("user_module_progress")
      .upsert(moduleRows, { onConflict: "user_id,module_id" });
    if (error) throw error;
  }

  if (practiceRows.length > 0) {
    const { error } = await supabase
      .from("user_practice_item_progress")
      .upsert(practiceRows, { onConflict: "user_id,module_id,item_id" });
    if (error) throw error;
  }
}
