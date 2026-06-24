"use client";

import { CourseSidebar } from "@/components/course-sidebar";
import { CourseSurface } from "@/components/course-surface";
import {
  type CompletionState,
  type CourseLevel,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";

function LearningIntro(props: {
  completedCount: number;
  courseFramework: string;
  levelLabel: string;
  totalCount: number;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        How learning works
      </p>
      <p className="mt-3 text-sm leading-7 text-stone-200">
        Choose a module, start the lesson, listen to the tutor phrase, say it
        out loud, record yourself if your browser supports it, and move through
        the guided steps until the module is complete.
      </p>
      <div className="mt-4 flex flex-wrap gap-3">
        <IntroBadge label={`${props.completedCount}/${props.totalCount} modules done`} />
        <IntroBadge label={props.levelLabel} />
        <IntroBadge label={props.courseFramework} />
      </div>
    </div>
  );
}

function IntroBadge(props: { label: string }) {
  return (
    <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.2em] text-stone-200">
      {props.label}
    </span>
  );
}

export function CourseLayout(props: {
  activeLevelId: string;
  activeModule: CourseModule;
  activeModuleId: string;
  activeProgress: {
    currentTurn: number;
    lastTranscript: string;
    state: CompletionState;
  };
  completedCount: number;
  courseFramework: string;
  levelLabel: string;
  onComplete: () => void;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
  onStart: () => void;
  onTranscriptChange: (value: string) => void;
  onTurnChange: (turn: number) => void;
  progressMap: Record<string, CompletionState>;
  slug: CourseSlug;
  totalCount: number;
}) {
  return (
    <section className="grid gap-6 lg:grid-cols-[0.3fr_0.7fr]">
      <CourseSidebar
        slug={props.slug}
        activeLevelId={props.activeLevelId}
        activeModuleId={props.activeModuleId}
        progressMap={props.progressMap}
        onSelectModule={props.onSelectModule}
      />
      <CourseLayoutMain {...props} />
    </section>
  );
}

function CourseLayoutMain(
  props: Omit<
    Parameters<typeof CourseLayout>[0],
    "activeLevelId" | "activeModuleId" | "onSelectModule" | "progressMap"
  >,
) {
  return (
    <section className="space-y-4">
      <LearningIntro
        completedCount={props.completedCount}
        totalCount={props.totalCount}
        levelLabel={props.levelLabel}
        courseFramework={props.courseFramework}
      />
      <CourseSurface
        slug={props.slug}
        module={props.activeModule}
        activeState={props.activeProgress.state}
        completedCount={props.completedCount}
        currentTurn={props.activeProgress.currentTurn}
        lastTranscript={props.activeProgress.lastTranscript}
        onStart={props.onStart}
        onTurnChange={props.onTurnChange}
        onTranscriptChange={props.onTranscriptChange}
        onComplete={props.onComplete}
        totalCount={props.totalCount}
      />
    </section>
  );
}
