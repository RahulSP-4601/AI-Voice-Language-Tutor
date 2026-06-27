"use client";

import { CourseSidebar } from "@/components/course-sidebar";
import { CourseStudyBank } from "@/components/course-study-bank";
import {
  type CompletionState,
  type CourseLevel,
  type LanguageCourseDefinition,
  type LanguageCourseResources,
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";
import { type StoredPracticeItemProgress } from "@/lib/course-progress";

function LearningIntro(props: {
  completedCount: number;
  course: LanguageCourseDefinition;
  levelLabel: string;
  totalCount: number;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        Live Course
      </p>
      <p className="mt-3 max-w-4xl text-sm leading-7 text-stone-200">
        Learn {props.course.name} by hearing the word, understanding its
        meaning in English, speaking it aloud, and saving your progress as you
        go.
      </p>
      <div className="mt-4 flex flex-wrap gap-3">
        <IntroBadge label={props.levelLabel} />
        <IntroBadge label={`${props.completedCount}/${props.totalCount} modules done`} />
        <IntroBadge label={props.course.lessonDuration} />
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
  activeLevelCompletedCount: number;
  activeLevelId: string;
  activeModule: CourseModule;
  activeModuleId: string;
  activeProgress: {
    practiceItems: Record<string, StoredPracticeItemProgress>;
  };
  course: LanguageCourseDefinition;
  courseResources?: LanguageCourseResources;
  levelLabel: string;
  onPracticeItemChange: (itemId: string, value: StoredPracticeItemProgress) => void;
  onSelectModule: (level: CourseLevel, module: CourseModule) => void;
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
        completedCount={props.activeLevelCompletedCount}
        course={props.course}
        totalCount={props.totalCount}
        levelLabel={props.levelLabel}
      />
      <CourseStudyBank
        module={props.activeModule}
        onPracticeItemChange={props.onPracticeItemChange}
        practiceItems={props.activeProgress.practiceItems}
        resources={props.courseResources}
        slug={props.slug}
      />
    </section>
  );
}
