"use client";

import Link from "next/link";
import { DashboardCourseTabs } from "@/components/dashboard-sections";
import { useCourseDefinition } from "@/components/use-course-definition";
import {
  type CourseLevel,
  type CourseSlug,
} from "@/lib/course-definitions";
import { getLevelRoute } from "@/lib/course-routing";

function LevelCard(props: { level: CourseLevel; slug: CourseSlug }) {
  return (
    <Link
      href={getLevelRoute(props.slug, props.level)}
      className="rounded-[1.5rem] border border-white/10 bg-white/[0.045] p-5 transition hover:-translate-y-0.5 hover:border-white/20 hover:bg-white/[0.08]"
    >
      <p className="text-lg font-semibold text-white">
        {props.level.officialLabel}
      </p>
      <p className="mt-1 text-xs uppercase tracking-[0.22em] text-amber-100">
        {props.level.productLabel}
      </p>
      <p className="mt-4 text-sm leading-7 text-stone-300">
        {props.level.objective}
      </p>
      <div className="mt-5 flex flex-wrap gap-3">
        <LevelMeta label={`${props.level.modules.length} lessons`} />
        <LevelMeta label={props.level.examConfig.title} />
      </div>
    </Link>
  );
}

function LevelMeta(props: { label: string }) {
  return (
    <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.18em] text-stone-300">
      {props.label}
    </span>
  );
}

function LevelGrid(props: { levels: CourseLevel[]; slug: CourseSlug }) {
  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      {props.levels.map((level) => (
        <LevelCard key={level.id} level={level} slug={props.slug} />
      ))}
    </div>
  );
}

export function CourseLevelSelector(props: { slug: CourseSlug }) {
  const courseState = useCourseDefinition(props.slug);
  const course = courseState.course;

  if (courseState.loading || !course) {
    return (
      <div className="rounded-[1.9rem] border border-white/10 bg-white/[0.04] px-6 py-5 text-sm text-stone-300">
        Loading difficulty options...
      </div>
    );
  }

  return (
    <section className="space-y-8">
      <DashboardCourseTabs activeSlug={props.slug} />
      <div className="rounded-[1.75rem] border border-white/10 bg-white/[0.04] p-6">
        <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
          Select difficulty
        </p>
        <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
          Pick your {course.name} level before you start learning.
        </h1>
        <p className="mt-4 max-w-3xl text-base leading-8 text-stone-300">
          Choose one level path first so the lesson view stays focused, clean,
          and built around the exact difficulty you want to practice.
        </p>
      </div>
      <LevelGrid levels={course.framework.levels} slug={props.slug} />
    </section>
  );
}
