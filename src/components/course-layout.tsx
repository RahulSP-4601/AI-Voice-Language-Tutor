"use client";

import { CourseSidebar } from "@/components/course-sidebar";
import { CourseStudyBank } from "@/components/course-study-bank";
import { CourseSurface } from "@/components/course-surface";
import {
  type CompletionState,
  type CourseLevel,
  type LanguageCourseDefinition,
  type LanguageCourseResources,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";

function LearningIntro(props: {
  activeModule: CourseModule;
  completedCount: number;
  course: LanguageCourseDefinition;
  levelLabel: string;
  totalCount: number;
}) {
  return (
    <div className="grid gap-4 xl:grid-cols-[minmax(0,1.2fr)_minmax(280px,0.8fr)]">
      <CourseBriefing {...props} />
      <CurrentMissionCard activeModule={props.activeModule} />
    </div>
  );
}

function CourseBriefing(props: {
  completedCount: number;
  course: LanguageCourseDefinition;
  levelLabel: string;
  totalCount: number;
}) {
  return (
    <div className="rounded-[1.7rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.12),rgba(255,255,255,0.03))] p-6">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        Course Briefing
      </p>
      <h2 className="mt-4 max-w-3xl text-3xl font-semibold tracking-[-0.04em] text-white sm:text-4xl">
        {props.course.name} {props.levelLabel} is built to be spoken, not just
        memorized.
      </h2>
      <p className="mt-4 max-w-3xl text-base leading-8 text-stone-200">
        {props.course.heroSummary}
      </p>
      <div className="mt-5 flex flex-wrap gap-3">
        <IntroBadge label={`${props.completedCount}/${props.totalCount} modules done`} />
        <IntroBadge label={props.course.framework.name} />
        <IntroBadge label={props.course.lessonDuration} />
      </div>
    </div>
  );
}

function CurrentMissionCard(props: { activeModule: CourseModule }) {
  return (
    <div className="rounded-[1.7rem] border border-white/10 bg-black/20 p-6">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Current Mission
      </p>
      <h3 className="mt-4 text-2xl font-semibold text-white">
        {props.activeModule.title}
      </h3>
      <p className="mt-3 text-sm leading-7 text-stone-300">
        {props.activeModule.supportLanguageHint}
      </p>
      <div className="mt-5 grid gap-3">
        <IntroBadge label={props.activeModule.checkpointLabel} />
        <IntroBadge label={`${props.activeModule.reward.xp} xp reward`} />
        <IntroBadge
          label={`${props.activeModule.progress.totalLessons} lesson mission`}
        />
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
  course: LanguageCourseDefinition;
  courseResources?: LanguageCourseResources;
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
        course={props.course}
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
        activeModule={props.activeModule}
        completedCount={props.completedCount}
        course={props.course}
        totalCount={props.totalCount}
        levelLabel={props.levelLabel}
      />
      <CourseSurface
        course={props.course}
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
      <CourseStudyBank
        module={props.activeModule}
        resources={props.courseResources}
      />
    </section>
  );
}
