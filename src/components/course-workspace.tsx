"use client";

import { type Dispatch, type SetStateAction, useState } from "react";
import { CourseLayout } from "@/components/course-layout";
import { useCourseDefinition } from "@/components/use-course-definition";
import { useCourseProgress } from "@/components/use-course-progress";
import {
  type CourseLevel,
  type LanguageCourseDefinition,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";
import { findLevelByRouteParam } from "@/lib/course-routing";
import {
  buildModulePracticeCards,
  type ModulePracticeDeck,
} from "@/lib/module-practice";
import {
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

function getPreferredSelection(
  course: LanguageCourseDefinition,
  preferredLevel?: string,
) {
  if (!preferredLevel) {
    return getDefaultSelection(course);
  }

  const level = findLevelByRouteParam(course.framework.levels, preferredLevel);
  if (!level || level.modules.length === 0) {
    return null;
  }

  return { levelId: level.id, moduleId: level.modules[0].id };
}

function hasCourseShape(course: LanguageCourseDefinition) {
  return course.framework.levels.length > 0 && course.framework.levels.some(
    (level) => level.modules.length > 0,
  );
}

function getResolvedCourseSetup(
  course: LanguageCourseDefinition | null,
  preferredLevel: string | undefined,
  progress: NonNullable<ReturnType<typeof useCourseProgress>["progress"]> | null,
) {
  if (!course || !hasCourseShape(course)) {
    return null;
  }

  if (!progress) {
    return { course, progress: null, selection: null };
  }

  return {
    course,
    progress,
    selection: getPreferredSelection(course, preferredLevel),
  };
}

export function CourseWorkspace(props: {
  activeSlug: CourseSlug;
  preferredLevel?: string;
}) {
  const data = useActiveCourse(props.activeSlug, props.preferredLevel);

  if (data.ready === "missing") {
    return (
      <div className="rounded-[1.9rem] border border-amber-300/20 bg-amber-300/[0.06] px-6 py-5 text-sm leading-7 text-amber-50">
        This course level is not available yet. Refresh after the latest course
        import, or choose a different level from the difficulty screen.
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

function useActiveCourse(slug: CourseSlug, preferredLevel?: string) {
  const courseState = useCourseDefinition(slug);
  const course = courseState.course;
  const [selection, setSelection] = useState<CourseSelection | null>(null);
  const { progress, ready, setProgress } = useCourseProgress(slug, course);

  if (courseState.loading) {
    return { ready: false } as const;
  }

  const setup = getResolvedCourseSetup(course, preferredLevel, progress);
  if (!setup) {
    return { ready: "missing" } as const;
  }

  if (!setup.progress) {
    return { ready: false } as const;
  }

  if (!setup.selection) {
    return { ready: "missing" } as const;
  }

  const activeSelection = selection ?? setup.selection;
  return buildCourseWorkspaceState({
    course: setup.course,
    progress: setup.progress,
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
  const practiceDeck = buildModulePracticeCards(input.course, activeModule.id);
  const progressSummary = buildProgressSummary(input.progress, activeLevel);

  return {
    activeLevel,
    activeLevelCompletedCount: progressSummary.activeLevelCompletedCount,
    activeLevelId: activeLevel.id,
    activeModule,
    activeModuleId: activeModule.id,
    course: input.course,
    activeProgress,
    practiceDeck,
    levelLabel: activeLevel.officialLabel,
    onPracticeItemChange: (itemId: string, value: StoredPracticeItemProgress) =>
      setPracticeItem(
        updateActiveModule,
        practiceDeck,
        itemId,
        value,
      ),
    onSelectModule: (level: CourseLevel, module: CourseModule) =>
      input.setSelection({ levelId: level.id, moduleId: module.id }),
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

function setPracticeItem(
  update: ReturnType<typeof createModuleUpdater>,
  practiceDeck: ModulePracticeDeck,
  itemId: string,
  value: StoredPracticeItemProgress,
) {
  update((current) => ({
    ...buildNextModuleProgress(current, practiceDeck, itemId, value),
  }));
}

function buildNextModuleProgress(
  current: StoredModuleProgress,
  practiceDeck: ModulePracticeDeck,
  itemId: string,
  value: StoredPracticeItemProgress,
) {
  const practiceItems = {
    ...current.practiceItems,
    [itemId]: value,
  };
  const itemIds = practiceDeck.all.map((item) => item.id);
  const hasPracticeCards = itemIds.length > 0;
  const allDone =
    hasPracticeCards &&
    itemIds.every((id) => practiceItems[id]?.done);
  const anyTouched = itemIds.some((id) => {
    const progress = practiceItems[id];
    return Boolean(progress?.done) || typeof progress?.lastScore === "number";
  });

  return {
    ...current,
    completedAt: allDone ? new Date().toISOString() : null,
    practiceItems,
    sessionsStarted: anyTouched ? Math.max(current.sessionsStarted, 1) : current.sessionsStarted,
    state: allDone ? "completed" : anyTouched ? "in_progress" : "not_started",
  } satisfies StoredModuleProgress;
}
