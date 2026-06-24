"use client";

import { useMemo, useState } from "react";
import {
  courseDefinitions,
  type CompletionState,
  type CourseLevel,
  type CourseModule,
  type CourseSlug,
  type LanguageCourseDefinition,
} from "@/lib/course-definitions";

function getStateLabel(state: CompletionState) {
  if (state === "completed") {
    return "Completed";
  }

  if (state === "in_progress") {
    return "In progress";
  }

  return "Not started";
}

function getStateClasses(state: CompletionState) {
  if (state === "completed") {
    return "border-emerald-300/30 bg-emerald-300/14 text-emerald-100";
  }

  if (state === "in_progress") {
    return "border-amber-300/25 bg-amber-300/10 text-amber-100";
  }

  return "border-white/10 bg-white/[0.04] text-stone-300";
}

function buildProgressMap(course: LanguageCourseDefinition) {
  return Object.fromEntries(
    course.framework.levels.flatMap((level) =>
      level.modules.map((module) => [module.id, module.completionState]),
    ),
  );
}

function getDefaultSelection(course: LanguageCourseDefinition) {
  const firstLevel =
    course.framework.levels.find((level) =>
      level.modules.some((module) => module.completionState !== "completed"),
    ) ?? course.framework.levels[0];

  const firstModule =
    firstLevel.modules.find((module) => module.completionState !== "completed") ??
    firstLevel.modules[0];

  return {
    levelId: firstLevel.id,
    moduleId: firstModule.id,
  };
}

function getLessonCountLabel(module: CourseModule) {
  return `${module.progress.totalLessons} lesson${
    module.progress.totalLessons === 1 ? "" : "s"
  }`;
}

export function CourseWorkspace(props: { activeSlug: CourseSlug }) {
  const course = courseDefinitions[props.activeSlug];
  const initialSelection = useMemo(() => getDefaultSelection(course), [course]);
  const [selectedLevelId, setSelectedLevelId] = useState(initialSelection.levelId);
  const [selectedModuleId, setSelectedModuleId] = useState(initialSelection.moduleId);
  const [progressMap, setProgressMap] = useState(() => buildProgressMap(course));

  const selectedLevel =
    course.framework.levels.find((level) => level.id === selectedLevelId) ??
    course.framework.levels[0];
  const selectedModule =
    selectedLevel.modules.find((module) => module.id === selectedModuleId) ??
    selectedLevel.modules[0];

  function selectModule(level: CourseLevel, module: CourseModule) {
    setSelectedLevelId(level.id);
    setSelectedModuleId(module.id);
  }

  function updateModuleState(nextState: CompletionState) {
    setProgressMap((current) => ({
      ...current,
      [selectedModule.id]: nextState,
    }));
  }

  return (
    <section className="grid gap-6 lg:grid-cols-[0.3fr_0.7fr]">
      <CourseSidebar
        course={course}
        progressMap={progressMap}
        selectedLevelId={selectedLevel.id}
        selectedModuleId={selectedModule.id}
        onSelectModule={selectModule}
      />
      <LessonSurface
        course={course}
        level={selectedLevel}
        module={selectedModule}
        moduleState={progressMap[selectedModule.id]}
        onUpdateModuleState={updateModuleState}
      />
    </section>
  );
}

function CourseSidebar(props: {
  course: LanguageCourseDefinition;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
  progressMap: Record<string, CompletionState>;
  selectedLevelId: string;
  selectedModuleId: string;
}) {
  return (
    <aside className="rounded-[1.9rem] border border-white/10 bg-white/[0.04] p-5">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.course.name}
      </p>
      <p className="mt-2 text-sm text-stone-400">
        {props.course.framework.name} course framework
      </p>
      <div className="mt-6 space-y-4">
        {props.course.framework.levels.map((level) => (
          <LevelSection
            key={level.id}
            level={level}
            progressMap={props.progressMap}
            selectedLevelId={props.selectedLevelId}
            selectedModuleId={props.selectedModuleId}
            onSelectModule={props.onSelectModule}
          />
        ))}
      </div>
    </aside>
  );
}

function LevelSection(props: {
  level: CourseLevel;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
  progressMap: Record<string, CompletionState>;
  selectedLevelId: string;
  selectedModuleId: string;
}) {
  const isActive = props.level.id === props.selectedLevelId;

  return (
    <section className="rounded-[1.45rem] border border-white/8 bg-black/20 p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-base font-semibold text-white">
            {props.level.officialLabel}
          </p>
          <p className="mt-1 text-xs uppercase tracking-[0.22em] text-stone-400">
            {props.level.productLabel}
          </p>
        </div>
        <span
          className={`rounded-full border px-3 py-1 text-[11px] uppercase tracking-[0.2em] ${
            isActive
              ? "border-amber-300/25 bg-amber-300/10 text-amber-100"
              : "border-white/10 bg-white/[0.04] text-stone-400"
          }`}
        >
          {props.level.modules.length} modules
        </span>
      </div>
      <p className="mt-3 text-sm leading-6 text-stone-400">
        {props.level.objective}
      </p>
      <div className="mt-4 space-y-2">
        {props.level.modules.map((module) => (
          <ModuleRow
            key={module.id}
            level={props.level}
            module={module}
            state={props.progressMap[module.id]}
            isSelected={module.id === props.selectedModuleId}
            onSelectModule={props.onSelectModule}
          />
        ))}
      </div>
    </section>
  );
}

function ModuleRow(props: {
  isSelected: boolean;
  level: CourseLevel;
  module: CourseModule;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
  state: CompletionState;
}) {
  return (
    <button
      type="button"
      onClick={() => props.onSelectModule(props.level, props.module)}
      className={`w-full rounded-[1.2rem] border px-3 py-3 text-left transition ${
        props.isSelected
          ? "border-amber-300/30 bg-amber-300/10"
          : "border-white/8 bg-white/[0.03] hover:border-white/16 hover:bg-white/[0.06]"
      }`}
    >
      <div className="flex items-start gap-3">
        <span
          className={`mt-0.5 flex h-6 w-6 items-center justify-center rounded-full text-xs font-semibold ${getStateClasses(
            props.state,
          )}`}
        >
          {props.state === "completed" ? "✓" : props.state === "in_progress" ? "•" : ""}
        </span>
        <div className="min-w-0">
          <p className="text-sm font-medium text-white">{props.module.title}</p>
          <p className="mt-1 text-xs leading-5 text-stone-400">
            {props.module.objective}
          </p>
        </div>
      </div>
    </button>
  );
}

function LessonSurface(props: {
  course: LanguageCourseDefinition;
  level: CourseLevel;
  module: CourseModule;
  moduleState: CompletionState;
  onUpdateModuleState: (nextState: CompletionState) => void;
}) {
  const leadLesson = props.module.lessons[0];

  return (
    <section className="rounded-[1.9rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.course.name} live lesson
      </p>
      <div className="mt-5 flex flex-wrap gap-3">
        <SurfaceBadge label={props.level.officialLabel} />
        <SurfaceBadge label={props.level.productLabel} />
        <SurfaceBadge label={getStateLabel(props.moduleState)} />
        <SurfaceBadge label={props.course.lessonDuration} />
      </div>
      <h1 className="mt-5 text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
        {props.module.title}
      </h1>
      <p className="mt-4 max-w-4xl text-base leading-8 text-stone-200">
        {props.module.objective}
      </p>
      <div className="mt-8 grid gap-4 xl:grid-cols-[minmax(0,1.2fr)_minmax(320px,0.8fr)]">
        <TutorLoopCard lesson={leadLesson} />
        <ProgressPanel
          course={props.course}
          level={props.level}
          module={props.module}
          moduleState={props.moduleState}
          onUpdateModuleState={props.onUpdateModuleState}
        />
      </div>
    </section>
  );
}

function SurfaceBadge(props: { label: string }) {
  return (
    <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.2em] text-stone-200">
      {props.label}
    </span>
  );
}

function TutorLoopCard(props: { lesson: CourseModule["lessons"][number] }) {
  return (
    <div className="rounded-[1.55rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Real-time tutor loop
      </p>
      <h2 className="mt-4 text-2xl font-semibold text-white">
        {props.lesson.title}
      </h2>
      <div className="mt-4 grid gap-3">
        {props.lesson.turns.map((turn, index) => (
          <div
            key={turn.id}
            className="rounded-[1.2rem] border border-white/8 bg-white/[0.04] p-4"
          >
            <div className="flex items-center gap-3">
              <span className="flex h-7 w-7 items-center justify-center rounded-full bg-amber-300/12 text-xs font-semibold text-amber-100">
                {index + 1}
              </span>
              <p className="text-sm font-medium text-white">{turn.label}</p>
            </div>
            <p className="mt-3 text-sm leading-6 text-stone-200">{turn.prompt}</p>
            <p className="mt-2 text-xs leading-5 text-stone-400">
              {turn.supportNote}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}

function ProgressPanel(props: {
  course: LanguageCourseDefinition;
  level: CourseLevel;
  module: CourseModule;
  moduleState: CompletionState;
  onUpdateModuleState: (nextState: CompletionState) => void;
}) {
  return (
    <div className="space-y-4">
      <ModuleProgressCard {...props} />
      <LessonTargetCard level={props.level} module={props.module} />
    </div>
  );
}

function ModuleProgressCard(props: {
  course: LanguageCourseDefinition;
  module: CourseModule;
  moduleState: CompletionState;
  onUpdateModuleState: (nextState: CompletionState) => void;
}) {
  return (
    <div className="rounded-[1.55rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        Module progress
      </p>
      <div className="mt-4 space-y-3">
        <ProgressRow label="Status" value={getStateLabel(props.moduleState)} />
        <ProgressRow label="Checkpoint" value={props.module.checkpointLabel} />
        <ProgressRow label="Lessons" value={getLessonCountLabel(props.module)} />
        <ProgressRow label="Support" value={props.course.nativeSupportLabel} />
      </div>
      <div className="mt-5 flex flex-wrap gap-3">
        <ActionButton
          label="Start module"
          onClick={() => props.onUpdateModuleState("in_progress")}
        />
        <ActionButton
          label="Mark complete"
          onClick={() => props.onUpdateModuleState("completed")}
        />
        <ActionButton
          label="Reset"
          muted
          onClick={() => props.onUpdateModuleState("not_started")}
        />
      </div>
    </div>
  );
}

function LessonTargetCard(props: {
  level: CourseLevel;
  module: CourseModule;
}) {
  const lesson = props.module.lessons[0];

  return (
    <div className="rounded-[1.55rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Lesson target
      </p>
      <h3 className="mt-4 text-xl font-semibold text-white">
        {lesson.targetPattern}
      </h3>
      <p className="mt-3 text-sm leading-6 text-stone-300">
        {lesson.learnerOutcome}
      </p>
      <div className="mt-5 space-y-3">
        <ProgressRow label="Feedback focus" value={lesson.feedback.focus} />
        <ProgressRow label="Success signal" value={lesson.feedback.successSignal} />
        <ProgressRow label="Exam" value={props.level.examConfig.title} />
        <ProgressRow
          label="Certificate"
          value={props.level.certificateConfig.title}
        />
      </div>
    </div>
  );
}

function ProgressRow(props: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-white/[0.04] px-4 py-3">
      <p className="text-xs uppercase tracking-[0.2em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-2 text-sm leading-6 text-white">{props.value}</p>
    </div>
  );
}

function ActionButton(props: {
  label: string;
  muted?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={props.onClick}
      className={`rounded-full border px-4 py-2 text-sm font-medium transition ${
        props.muted
          ? "border-white/10 bg-white/[0.04] text-stone-200 hover:bg-white/[0.08]"
          : "border-amber-300/20 bg-amber-300/12 text-amber-100 hover:bg-amber-300/18"
      }`}
    >
      {props.label}
    </button>
  );
}
