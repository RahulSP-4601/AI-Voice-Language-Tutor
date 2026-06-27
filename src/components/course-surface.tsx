"use client";

import { LessonRunner } from "@/components/lesson-runner";
import {
  type CompletionState,
  type CourseModule,
  type CourseSlug,
  type LanguageCourseDefinition,
} from "@/lib/course-definitions";
import { buildModulePracticeCards, findLessonMeaning } from "@/lib/module-practice";

function getStateLabel(state: CompletionState) {
  if (state === "completed") return "Completed";
  if (state === "in_progress") return "In progress";
  return "Not started";
}

function SurfaceBadge(props: { label: string }) {
  return (
    <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.2em] text-stone-200">
      {props.label}
    </span>
  );
}

export function CourseSurface(props: {
  activeState: CompletionState;
  completedCount: number;
  course: LanguageCourseDefinition;
  currentTurn: number;
  lastTranscript: string;
  module: CourseModule;
  onComplete: () => void;
  onStart: () => void;
  onTranscriptChange: (value: string) => void;
  onTurnChange: (turn: number) => void;
  slug: CourseSlug;
  totalCount: number;
}) {
  return (
    <section className="rounded-[1.9rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
      <SurfaceHeader
        course={props.course}
        lessonDuration={props.course.lessonDuration}
        meaning={getLessonMeaning(props.course, props.module)}
        module={props.module}
        state={props.activeState}
      />
      <LessonRunner
        key={props.module.id}
        slug={props.slug}
        lesson={props.module.lessons[0]}
        moduleId={props.module.id}
        moduleState={props.activeState}
        currentTurn={props.currentTurn}
        lastTranscript={props.lastTranscript}
        onStart={props.onStart}
        onTurnChange={props.onTurnChange}
        onTranscriptChange={props.onTranscriptChange}
        onComplete={props.onComplete}
        progressSummary={{
          completedCount: props.completedCount,
          learningGoal: props.module.objective,
          stateLabel: getStateLabel(props.activeState),
          totalCount: props.totalCount,
        }}
      />
    </section>
  );
}

function getLessonMeaning(
  course: LanguageCourseDefinition,
  module: CourseModule,
) {
  return findLessonMeaning(
    module.lessons[0],
    buildModulePracticeCards(course, module.id).all,
  );
}

function SurfaceHeader(props: {
  course: LanguageCourseDefinition;
  lessonDuration: string;
  meaning: string | null;
  module: CourseModule;
  state: CompletionState;
}) {
  const lesson = props.module.lessons[0];
  return (
    <div className="mb-8 space-y-5">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.course.name} voice session
      </p>
      <div className="flex flex-wrap gap-3">
        <SurfaceBadge label={lesson.mode} />
        <SurfaceBadge label={getStateLabel(props.state)} />
        <SurfaceBadge label={props.lessonDuration} />
      </div>
      <h1 className="text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
        {props.module.title}
      </h1>
      <p className="max-w-4xl text-base leading-8 text-stone-200">
        {props.module.objective}
      </p>
      <LiveTargetCard meaning={props.meaning} lesson={lesson} />
    </div>
  );
}

function LiveTargetCard(props: {
  lesson: CourseModule["lessons"][number];
  meaning: string | null;
}) {
  return (
    <div className="rounded-[1.5rem] border border-emerald-400/12 bg-emerald-500/[0.05] p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Speak this now
      </p>
      <p className="mt-4 text-3xl font-semibold text-white">
        {props.lesson.demoPhrase}
      </p>
      {props.meaning ? (
        <p className="mt-3 text-lg text-stone-100">Meaning: {props.meaning}</p>
      ) : null}
      <p className="mt-4 text-sm uppercase tracking-[0.18em] text-stone-400">
        Your goal
      </p>
      <p className="mt-2 text-base leading-7 text-stone-200">
        {props.lesson.replyPrompt}
      </p>
    </div>
  );
}
