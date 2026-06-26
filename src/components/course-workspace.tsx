"use client";

import { type Dispatch, type SetStateAction, useEffect, useState } from "react";
import { CourseLayout } from "@/components/course-layout";
import { useCourseCertificates } from "@/components/use-course-certificates";
import { useCourseDefinition } from "@/components/use-course-definition";
import { useCourseProgress } from "@/components/use-course-progress";
import { isLevelComplete } from "@/lib/course-certificates";
import {
  type CourseLevel,
  type LanguageCourseDefinition,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";
import {
  countCompletedModules,
  type StoredModuleProgress,
  type StoredPracticeItemProgress,
} from "@/lib/course-progress";

type CourseSelection = {
  levelId: string;
  moduleId: string;
};

function getDefaultSelection(course: LanguageCourseDefinition) {
  const firstLevel = course.framework.levels[0];
  const firstModule = firstLevel.modules[0];
  return { levelId: firstLevel.id, moduleId: firstModule.id };
}

export function CourseWorkspace(props: { activeSlug: CourseSlug }) {
  const data = useActiveCourse(props.activeSlug);

  if (data.ready === "missing") {
    return (
      <div className="rounded-[1.9rem] border border-amber-300/20 bg-amber-300/[0.06] px-6 py-5 text-sm leading-7 text-amber-50">
        Japanese course data is not available from Supabase yet. Paste
        [japanese-n5-curriculum.sql] into Supabase SQL Editor, then refresh this
        page.
      </div>
    );
  }

  if (!data.ready) {
    return (
      <div className="rounded-[1.9rem] border border-white/10 bg-white/[0.04] px-6 py-5 text-sm text-stone-300">
        Loading your lesson progress...
      </div>
    );
  }

  return <CourseLayout {...data} slug={props.activeSlug} />;
}

function useActiveCourse(slug: CourseSlug) {
  const courseState = useCourseDefinition(slug);
  const course = courseState.course;
  const [selection, setSelection] = useState<CourseSelection | null>(null);
  const { progress, ready, setProgress } = useCourseProgress(slug, course);
  const certificates = useCourseCertificates();

  useEffect(() => {
    if (!course || !progress || !ready || !certificates.ready) {
      return;
    }

    course.framework.levels.forEach((level) => {
      if (
        isLevelComplete(level, progress) &&
        !certificates.hasCertificate(course.slug, level.id)
      ) {
        certificates.issueLevelCertificate(course, level);
      }
    });
  }, [certificates, course, progress, ready]);

  if (courseState.loading) {
    return { ready: false } as const;
  }

  if (course === null) {
    return { ready: "missing" } as const;
  }

  if (!progress) {
    return { ready: false } as const;
  }

  const activeSelection = selection ?? getDefaultSelection(course);
  return buildCourseWorkspaceState({
    course,
    progress,
    ready,
    selection: activeSelection,
    setProgress,
    setSelection,
  });
}

function buildCourseWorkspaceState(input: {
  course: LanguageCourseDefinition;
  progress: NonNullable<ReturnType<typeof useCourseProgress>["progress"]>;
  ready: boolean;
  selection: CourseSelection;
  setProgress: ReturnType<typeof useCourseProgress>["setProgress"];
  setSelection: Dispatch<SetStateAction<CourseSelection | null>>;
}) {
  const activeLevel = findActiveLevel(
    input.course.framework.levels,
    input.selection.levelId,
  );
  const activeModule = findActiveModule(
    activeLevel.modules,
    input.selection.moduleId,
  );
  const activeProgress = input.progress.modules[activeModule.id];
  const updateActiveModule = createModuleUpdater(
    activeModule.id,
    input.setProgress,
  );
  const progressSummary = buildProgressSummary(input.progress, activeLevel);

  return {
    activeLevelCompletedCount: progressSummary.activeLevelCompletedCount,
    activeLevelId: activeLevel.id,
    activeModule,
    activeModuleId: activeModule.id,
    course: input.course,
    activeProgress,
    activePracticeItems: activeProgress.practiceItems,
    completedCount: countCompletedModules(input.progress),
    courseResources: input.course.resources,
    levelLabel: activeLevel.officialLabel,
    onComplete: () => completeModule(updateActiveModule),
    onPracticeItemChange: (itemId: string, value: StoredPracticeItemProgress) =>
      setPracticeItem(updateActiveModule, itemId, value),
    onSelectModule: (level: CourseLevel, module: CourseModule) =>
      input.setSelection({ levelId: level.id, moduleId: module.id }),
    onStart: () => startModule(updateActiveModule),
    onTranscriptChange: (value: string) => setTranscript(updateActiveModule, value),
    onTurnChange: (turn: number) => setTurn(updateActiveModule, turn),
    progressMap: progressSummary.progressMap,
    ready: input.ready,
    totalCount: progressSummary.totalCount,
  };
}

function buildProgressSummary(
  progress: NonNullable<ReturnType<typeof useCourseProgress>["progress"]>,
  activeLevel: CourseLevel,
) {
  return {
    activeLevelCompletedCount: activeLevel.modules.filter(
      (module) => progress.modules[module.id]?.state === "completed",
    ).length,
    progressMap: Object.fromEntries(
      Object.entries(progress.modules).map(([id, value]) => [id, value.state]),
    ),
    totalCount: activeLevel.modules.length,
  };
}

function findActiveLevel(levels: CourseLevel[], levelId: string) {
  return levels.find((level) => level.id === levelId) ?? levels[0];
}

function findActiveModule(modules: CourseModule[], moduleId: string) {
  return modules.find((module) => module.id === moduleId) ?? modules[0];
}

function createModuleUpdater(
  moduleId: string,
  setProgress: ReturnType<typeof useCourseProgress>["setProgress"],
) {
  return (updater: (current: StoredModuleProgress) => StoredModuleProgress) =>
    setProgress((current) =>
      current
        ? {
            ...current,
            modules: {
              ...current.modules,
              [moduleId]: updater(current.modules[moduleId]),
            },
          }
        : current,
    );
}

function completeModule(update: ReturnType<typeof createModuleUpdater>) {
  update((current) => ({
    ...current,
    completedAt: new Date().toISOString(),
    state: "completed",
  }));
}

function startModule(update: ReturnType<typeof createModuleUpdater>) {
  update((current) => ({
    ...current,
    state: "in_progress",
    sessionsStarted: current.sessionsStarted + 1,
  }));
}

function setTurn(update: ReturnType<typeof createModuleUpdater>, turn: number) {
  update((current) => ({ ...current, currentTurn: turn }));
}

function setTranscript(
  update: ReturnType<typeof createModuleUpdater>,
  value: string,
) {
  update((current) => ({ ...current, lastTranscript: value }));
}

function setPracticeItem(
  update: ReturnType<typeof createModuleUpdater>,
  itemId: string,
  value: StoredPracticeItemProgress,
) {
  update((current) => ({
    ...current,
    practiceItems: {
      ...current.practiceItems,
      [itemId]: value,
    },
  }));
}
