"use client";

import {
  courseDefinitions,
  type CompletionState,
  type CourseLevel,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";

function SidebarModule(props: {
  isSelected: boolean;
  module: CourseModule;
  onSelect: () => void;
  state: CompletionState;
}) {
  return (
    <button
      type="button"
      onClick={props.onSelect}
      className={`w-full rounded-[1.15rem] border px-3 py-3 text-left transition ${
        props.isSelected
          ? "border-amber-300/25 bg-amber-300/10"
          : "border-white/8 bg-white/[0.03] hover:border-white/15 hover:bg-white/[0.06]"
      }`}
    >
      <div className="flex items-start gap-3">
        <span className="mt-0.5 flex h-6 w-6 items-center justify-center rounded-full border border-white/10 bg-black/20 text-xs font-semibold text-white">
          {props.state === "completed" ? "✓" : props.state === "in_progress" ? "•" : ""}
        </span>
        <div>
          <p className="text-sm font-medium text-white">{props.module.title}</p>
          <p className="mt-1 text-xs leading-5 text-stone-400">
            {props.module.objective}
          </p>
        </div>
      </div>
    </button>
  );
}

function LevelSection(props: {
  activeLevelId: string;
  activeModuleId: string;
  level: CourseLevel;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
  progressMap: Record<string, CompletionState>;
}) {
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
            props.level.id === props.activeLevelId
              ? "border-amber-300/25 bg-amber-300/10 text-amber-100"
              : "border-white/10 bg-white/[0.04] text-stone-400"
          }`}
        >
          {props.level.modules.length} modules
        </span>
      </div>
      <div className="mt-4 space-y-2">
        {props.level.modules.map((module) => (
          <SidebarModule
            key={module.id}
            module={module}
            state={props.progressMap[module.id]}
            isSelected={module.id === props.activeModuleId}
            onSelect={() => props.onSelectModule(props.level, module)}
          />
        ))}
      </div>
    </section>
  );
}

export function CourseSidebar(props: {
  activeLevelId: string;
  activeModuleId: string;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
  progressMap: Record<string, CompletionState>;
  slug: CourseSlug;
}) {
  const course = courseDefinitions[props.slug];

  return (
    <aside className="rounded-[1.9rem] border border-white/10 bg-white/[0.04] p-5">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {course.name}
      </p>
      <p className="mt-2 text-sm text-stone-400">
        {course.framework.name} speaking path
      </p>
      <div className="mt-6 space-y-4">
        {course.framework.levels.map((level) => (
          <LevelSection
            key={level.id}
            level={level}
            activeLevelId={props.activeLevelId}
            activeModuleId={props.activeModuleId}
            onSelectModule={props.onSelectModule}
            progressMap={props.progressMap}
          />
        ))}
      </div>
    </aside>
  );
}
