"use client";

import { useState } from "react";
import { CourseLayout } from "@/components/course-layout";
import { useCourseProgress } from "@/components/use-course-progress";
import {
  type CompletionState,
  courseDefinitions,
  type CourseLevel,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";
import { countCompletedModules } from "@/lib/course-progress";

function getDefaultSelection(slug: CourseSlug) {
  const course = courseDefinitions[slug];
  const firstLevel = course.framework.levels[0];
  const featuredModule =
    slug === "japanese"
      ? firstLevel.modules.find((module) => module.id === "n5-greetings")
      : firstLevel.modules[0];
  const firstModule = featuredModule ?? firstLevel.modules[0];
  return { levelId: firstLevel.id, moduleId: firstModule.id };
}

export function CourseWorkspace(props: { activeSlug: CourseSlug }) {
  const data = useActiveCourse(props.activeSlug);

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
  const course = courseDefinitions[slug];
  const [selection, setSelection] = useState(getDefaultSelection(slug));
  const { progress, ready, setProgress } = useCourseProgress(slug);
  const activeLevel = findActiveLevel(course.framework.levels, selection.levelId);
  const activeModule = findActiveModule(activeLevel.modules, selection.moduleId);
  const activeProgress = progress.modules[activeModule.id];
  const updateActiveModule = createModuleUpdater(activeModule.id, setProgress);

  return {
    activeLevelId: activeLevel.id,
    activeModule,
    activeModuleId: activeModule.id,
    activeProgress,
    completedCount: countCompletedModules(progress),
    courseFramework: course.framework.name,
    levelLabel: activeLevel.officialLabel,
    onComplete: () => completeModule(updateActiveModule),
    onSelectModule: (level: CourseLevel, module: CourseModule) =>
      setSelection({ levelId: level.id, moduleId: module.id }),
    onStart: () => startModule(updateActiveModule),
    onTranscriptChange: (value: string) => setTranscript(updateActiveModule, value),
    onTurnChange: (turn: number) => setTurn(updateActiveModule, turn),
    progressMap: Object.fromEntries(
      Object.entries(progress.modules).map(([id, value]) => [id, value.state]),
    ),
    ready,
    totalCount: Object.keys(progress.modules).length,
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
  return (
    updater: (current: {
      completedAt: string | null;
      currentTurn: number;
      lastTranscript: string;
      sessionsStarted: number;
      state: CompletionState;
    }) => {
      completedAt: string | null;
      currentTurn: number;
      lastTranscript: string;
      sessionsStarted: number;
      state: CompletionState;
    },
  ) =>
    setProgress((current) => ({
      ...current,
      modules: {
        ...current.modules,
        [moduleId]: updater(current.modules[moduleId]),
      },
    }));
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
