"use client";

import { LessonRunner } from "@/components/lesson-runner";
import {
  type CompletionState,
  type LanguageCourseDefinition,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";

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
  const lesson = props.module.lessons[0];
  return (
    <section className="rounded-[1.9rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
      <SurfaceHeader
        course={props.course}
        lesson={lesson}
        mode={lesson.mode}
        state={props.activeState}
        module={props.module}
      />
      <SurfaceContent
        lesson={lesson}
        module={props.module}
        state={props.activeState}
        completedCount={props.completedCount}
        currentTurn={props.currentTurn}
        lastTranscript={props.lastTranscript}
        onComplete={props.onComplete}
        onStart={props.onStart}
        onTranscriptChange={props.onTranscriptChange}
        onTurnChange={props.onTurnChange}
        slug={props.slug}
        totalCount={props.totalCount}
      />
    </section>
  );
}

function SurfaceHeader(props: {
  course: LanguageCourseDefinition;
  lesson: CourseModule["lessons"][number];
  module: CourseModule;
  mode: string;
  state: CompletionState;
}) {
  return (
    <>
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.course.name} voice session
      </p>
      <div className="mt-5 flex flex-wrap gap-3">
        <SurfaceBadge label={props.mode} />
        <SurfaceBadge label={getStateLabel(props.state)} />
        <SurfaceBadge label={props.course.lessonDuration} />
      </div>
      <h1 className="mt-5 text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
        {props.module.title}
      </h1>
      <p className="mt-4 max-w-4xl text-base leading-8 text-stone-200">
        {props.module.objective}
      </p>
      <MissionOverview course={props.course} lesson={props.lesson} module={props.module} />
    </>
  );
}

function MissionOverview(props: {
  course: LanguageCourseDefinition;
  lesson: CourseModule["lessons"][number];
  module: CourseModule;
}) {
  return (
    <div className="mt-6 grid gap-4 xl:grid-cols-3">
      <MissionStory module={props.module} />
      <MissionSupport
        course={props.course}
        supportLanguageHint={props.module.supportLanguageHint}
      />
      <MissionReward course={props.course} reward={props.module.reward} />
      <VoiceTargetCard lesson={props.lesson} />
      <MissionCoverage coverage={props.module.experience.coverage} />
    </div>
  );
}

function MissionStory(props: { module: CourseModule }) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        {props.module.experience.missionTitle}
      </p>
      <p className="mt-4 text-sm leading-7 text-stone-200">
        {props.module.experience.storyHook}
      </p>
    </div>
  );
}

function MissionReward(props: {
  course: LanguageCourseDefinition;
  reward: CourseModule["reward"];
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Unlock reward
      </p>
      <p className="mt-4 text-lg font-semibold text-white">{props.reward.badge}</p>
      <p className="mt-2 text-sm leading-7 text-stone-300">
        Complete this mission and earn +{props.reward.xp} XP toward the full{" "}
        {props.course.framework.name} journey.
      </p>
    </div>
  );
}

function MissionSupport(props: {
  course: LanguageCourseDefinition;
  supportLanguageHint: string;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-sky-100">
        Support Style
      </p>
      <p className="mt-4 text-sm leading-7 text-stone-200">
        {props.supportLanguageHint}
      </p>
      <p className="mt-4 text-xs uppercase tracking-[0.22em] text-stone-400">
        {props.course.nativeSupportLabel}
      </p>
    </div>
  );
}

function VoiceTargetCard(props: { lesson: CourseModule["lessons"][number] }) {
  return (
    <div className="rounded-[1.5rem] border border-emerald-400/12 bg-emerald-500/[0.05] p-5 xl:col-span-2">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Speak This Mission
      </p>
      <p className="mt-4 text-3xl font-semibold text-white">
        {props.lesson.demoPhrase}
      </p>
      <p className="mt-4 text-sm uppercase tracking-[0.22em] text-stone-400">
        Your goal
      </p>
      <p className="mt-2 text-base leading-7 text-stone-200">
        {props.lesson.replyPrompt}
      </p>
      <p className="mt-4 text-sm leading-7 text-stone-300">
        {props.lesson.learnerOutcome}
      </p>
      <div className="mt-4 flex flex-wrap gap-2">
        {props.lesson.acceptableResponses.slice(0, 6).map((response) => (
          <span
            key={response}
            className="rounded-full border border-white/10 bg-black/20 px-3 py-2 text-xs text-stone-200"
          >
            {response}
          </span>
        ))}
      </div>
    </div>
  );
}

function MissionCoverage(props: { coverage: string[] }) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5 xl:col-span-3">
      <p className="text-xs uppercase tracking-[0.32em] text-stone-300">
        This mission covers
      </p>
      <div className="mt-4 flex flex-wrap gap-2">
        {props.coverage.map((item) => (
          <span
            key={item}
            className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-2 text-xs uppercase tracking-[0.18em] text-stone-200"
          >
            {item}
          </span>
        ))}
      </div>
    </div>
  );
}

function SurfaceContent(props: {
  completedCount: number;
  currentTurn: number;
  lastTranscript: string;
  lesson: CourseModule["lessons"][number];
  module: CourseModule;
  onComplete: () => void;
  onStart: () => void;
  onTranscriptChange: (value: string) => void;
  onTurnChange: (turn: number) => void;
  slug: CourseSlug;
  state: CompletionState;
  totalCount: number;
}) {
  return (
    <div className="mt-8">
      <LessonRunner
        key={props.module.id}
        slug={props.slug}
        lesson={props.lesson}
        moduleId={props.module.id}
        moduleState={props.state}
        currentTurn={props.currentTurn}
        lastTranscript={props.lastTranscript}
        onStart={props.onStart}
        onTurnChange={props.onTurnChange}
        onTranscriptChange={props.onTranscriptChange}
        onComplete={props.onComplete}
        progressSummary={{
          checkpoint: props.module.checkpointLabel,
          completedCount: props.completedCount,
          learningGoal: props.module.objective,
          stateLabel: getStateLabel(props.state),
          totalCount: props.totalCount,
        }}
      />
    </div>
  );
}
