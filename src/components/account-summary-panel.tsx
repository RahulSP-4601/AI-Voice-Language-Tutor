"use client";

import Link from "next/link";
import {
  dashboardCourses,
  type DashboardCourseSlug,
} from "@/lib/product-content";
import { useCourseDefinition } from "@/components/use-course-definition";
import { useCourseProgress } from "@/components/use-course-progress";
import { type CourseLevel } from "@/lib/course-definitions";
import {
  getCourseAvailabilityLabel,
  isCourseReleased,
} from "@/lib/course-presentation";
import { buildCoursePracticeMap } from "@/lib/module-practice";
import { type StoredCourseProgress } from "@/lib/course-progress";

function SummaryMetric(props: { label: string; value: string }) {
  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5">
      <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-3 text-2xl font-semibold text-white">{props.value}</p>
    </div>
  );
}

function countCompletedWords(
  progress: StoredCourseProgress | null,
  moduleId: string,
  itemIds: string[],
) {
  if (!progress) {
    return 0;
  }

  const practiceItems = progress.modules[moduleId]?.practiceItems ?? {};
  return itemIds.filter((itemId) => practiceItems[itemId]?.done).length;
}

function buildLevelRows(
  level: CourseLevel,
  progress: StoredCourseProgress | null,
  practiceMap: ReturnType<typeof buildCoursePracticeMap>,
) {
  return level.modules.map((module, index) => {
    const deck = practiceMap[module.id];
    const itemIds = deck?.all.map((item) => item.id) ?? [];
    return {
      completedWords: countCompletedWords(progress, module.id, itemIds),
      label: `${level.officialLabel} L${index + 1}`,
      totalWords: itemIds.length,
    };
  });
}

function ProgressRow(props: {
  completedWords: number;
  label: string;
  totalWords: number;
}) {
  return (
    <div className="rounded-[1.1rem] border border-white/8 bg-[#131a1d] px-4 py-3">
      <div className="flex items-center justify-between gap-4">
        <p className="text-sm font-medium text-white">{props.label}</p>
        <p className="text-sm text-amber-100">
          {props.completedWords} / {props.totalWords}
        </p>
      </div>
      <p className="mt-2 text-xs leading-6 text-stone-400">
        {props.completedWords} words completed out of {props.totalWords} words
      </p>
    </div>
  );
}

function JapaneseProgressBox() {
  const { course, loading } = useCourseDefinition("japanese");
  const { progress, ready } = useCourseProgress("japanese", course);

  if (loading || !course || !ready || !progress) {
    return (
      <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.04] p-5">
        <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
          Japanese progress
        </p>
        <p className="mt-3 text-sm leading-7 text-stone-300">
          Loading saved progress...
        </p>
      </div>
    );
  }

  const practiceMap = buildCoursePracticeMap(course);
  const rows = course.framework.levels.flatMap((level) =>
    buildLevelRows(level, progress, practiceMap),
  );

  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5">
      <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
        Japanese progress
      </p>
      <div className="mt-4 grid gap-3 lg:grid-cols-2">
        {rows.map((row) => (
          <ProgressRow
            key={row.label}
            label={row.label}
            completedWords={row.completedWords}
            totalWords={row.totalWords}
          />
        ))}
      </div>
    </div>
  );
}

function CourseAccessCard(props: {
  href: string;
  name: string;
  slug: DashboardCourseSlug;
}) {
  const available = isCourseReleased(props.slug);

  if (!available) {
    return (
      <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.03] p-5 opacity-80">
        <div className="flex items-center justify-between gap-4">
          <p className="text-lg font-semibold text-white">{props.name}</p>
          <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.2em] text-stone-400">
            {getCourseAvailabilityLabel(props.slug)}
          </span>
        </div>
        <p className="mt-3 text-sm leading-7 text-stone-400">
          This course is locked until the live lesson path is ready.
        </p>
      </div>
    );
  }

  return (
    <Link
      href={props.href}
      className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5 transition hover:border-white/20 hover:bg-white/[0.08]"
    >
      <div className="flex items-center justify-between gap-4">
        <p className="text-lg font-semibold text-white">{props.name}</p>
        <span className="rounded-full border border-emerald-300/30 bg-emerald-300/12 px-3 py-1 text-xs uppercase tracking-[0.2em] text-emerald-100">
          Free
        </span>
      </div>
      <p className="mt-3 text-sm leading-7 text-stone-300">
        Open the course and continue learning from your saved lesson progress.
      </p>
    </Link>
  );
}

export function AccountSummaryPanel() {
  const availableCount = dashboardCourses.filter((course) =>
    isCourseReleased(course.slug),
  ).length;

  return (
    <section className="rounded-[2rem] border border-white/10 bg-white/[0.045] p-7">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        Learning account
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
        Free access and saved progress
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-8 text-stone-300">
        All courses stay free. Your account keeps track of course access and ongoing learning progress.
      </p>
      <div className="mt-8 grid gap-4 lg:grid-cols-2">
        <SummaryMetric label="Course access" value="All free" />
        <SummaryMetric label="Available now" value={String(availableCount)} />
      </div>
      <div className="mt-8">
        <JapaneseProgressBox />
      </div>
      <div className="mt-8 grid gap-4 lg:grid-cols-3">
        {dashboardCourses.map((course) => (
          <CourseAccessCard
            key={course.slug}
            href={`/dashboard/${course.slug}`}
            name={course.name}
            slug={course.slug}
          />
        ))}
      </div>
    </section>
  );
}
