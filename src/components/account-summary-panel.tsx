"use client";

import Link from "next/link";
import { dashboardCourses } from "@/lib/product-content";
import { useCourseDefinition } from "@/components/use-course-definition";
import { useCourseProgress } from "@/components/use-course-progress";
import { type CourseLevel } from "@/lib/course-definitions";
import {
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

function sum(values: number[]) {
  return values.reduce((total, value) => total + value, 0);
}

function getLevelProgressGroups(
  course: NonNullable<ReturnType<typeof useCourseDefinition>["course"]>,
  progress: StoredCourseProgress,
) {
  const practiceMap = buildCoursePracticeMap(course);
  return course.framework.levels.map((level) => {
    const rows = buildLevelRows(level, progress, practiceMap);
    const completedWords = sum(rows.map((row) => row.completedWords));
    const totalWords = sum(rows.map((row) => row.totalWords));
    const startedRows = rows.filter((row) => row.completedWords > 0).length;

    return {
      completedWords,
      level,
      rows,
      startedRows,
      totalWords,
    };
  });
}

function getFocusedLevelIndex(
  groups: ReturnType<typeof getLevelProgressGroups>,
) {
  const startedIndex = groups.findIndex((group) => group.startedRows > 0);
  return startedIndex >= 0 ? startedIndex : 0;
}

function LevelSummaryCard(props: {
  completedWords: number;
  isActive: boolean;
  levelLabel: string;
  startedRows: number;
  totalWords: number;
}) {
  const ratio = props.totalWords > 0
    ? Math.min(100, Math.round((props.completedWords / props.totalWords) * 100))
    : 0;

  return (
    <div
      className={`rounded-[1.25rem] border p-4 ${
        props.isActive
          ? "border-amber-300/20 bg-amber-300/[0.08]"
          : "border-white/10 bg-[#131a1d]"
      }`}
    >
      <div className="flex items-center justify-between gap-3">
        <p className="text-base font-semibold text-white">{props.levelLabel}</p>
        <p className="text-sm text-amber-100">
          {props.completedWords} / {props.totalWords}
        </p>
      </div>
      <div className="mt-3 h-2 rounded-full bg-black/30">
        <div
          className="h-2 rounded-full bg-[linear-gradient(90deg,#f7c874_0%,#ff8c69_100%)]"
          style={{ width: `${ratio}%` }}
        />
      </div>
      <p className="mt-3 text-xs leading-6 text-stone-400">
        {props.startedRows} lesson boxes started
      </p>
    </div>
  );
}

function FocusStat(props: { label: string; value: string }) {
  return (
    <div className="rounded-[1.15rem] border border-white/10 bg-[#131a1d] p-4">
      <p className="text-xs uppercase tracking-[0.22em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-2 text-xl font-semibold text-white">{props.value}</p>
    </div>
  );
}

function JapaneseProgressLoading() {
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

function JapaneseProgressHeader(props: {
  currentLevel: string;
  startedLevels: number;
  totalCompletedWords: number;
  totalWords: number;
}) {
  return (
    <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
      <div>
        <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
          Japanese progress
        </p>
        <h2 className="mt-2 text-2xl font-semibold text-white">
          {props.currentLevel} is your current focus
        </h2>
        <p className="mt-2 text-sm leading-7 text-stone-300">
          Showing the current level in detail and the rest as compact summaries.
        </p>
      </div>
      <div className="grid gap-3 sm:grid-cols-3">
        <FocusStat
          label="Words done"
          value={`${props.totalCompletedWords} / ${props.totalWords}`}
        />
        <FocusStat
          label="Started levels"
          value={String(props.startedLevels)}
        />
        <FocusStat
          label="Current level"
          value={props.currentLevel}
        />
      </div>
    </div>
  );
}

function JapaneseLevelSummary(props: {
  focusedLevelIndex: number;
  groups: ReturnType<typeof getLevelProgressGroups>;
}) {
  return (
    <div className="mt-6 grid gap-3 lg:grid-cols-5">
      {props.groups.map((group, index) => (
        <LevelSummaryCard
          key={group.level.id}
          levelLabel={group.level.officialLabel}
          completedWords={group.completedWords}
          totalWords={group.totalWords}
          startedRows={group.startedRows}
          isActive={index === props.focusedLevelIndex}
        />
      ))}
    </div>
  );
}

function FocusedLevelDetail(props: {
  completedWords: number;
  levelLabel: string;
  rows: ReturnType<typeof getLevelProgressGroups>[number]["rows"];
  totalWords: number;
}) {
  return (
    <div className="mt-6 rounded-[1.25rem] border border-white/10 bg-[#101618] p-4">
      <div className="flex items-center justify-between gap-4">
        <div>
          <p className="text-sm uppercase tracking-[0.24em] text-amber-100">
            {props.levelLabel} lesson progress
          </p>
          <p className="mt-2 text-sm leading-6 text-stone-400">
            Organized by lesson box so the learner can scan progress quickly.
          </p>
        </div>
        <p className="text-sm text-stone-300">
          {props.completedWords} of {props.totalWords} words
        </p>
      </div>
      <div className="mt-4 grid gap-3 lg:grid-cols-2">
        {props.rows.map((row) => (
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

function JapaneseProgressBox() {
  const { course, loading } = useCourseDefinition("japanese");
  const { progress, ready } = useCourseProgress("japanese", course);

  if (loading || !course || !ready || !progress) {
    return <JapaneseProgressLoading />;
  }

  const groups = getLevelProgressGroups(course, progress);
  const focusedLevelIndex = getFocusedLevelIndex(groups);
  const focusedGroup = groups[focusedLevelIndex];
  const totalCompletedWords = sum(groups.map((group) => group.completedWords));
  const totalWords = sum(groups.map((group) => group.totalWords));
  const startedLevels = groups.filter((group) => group.startedRows > 0).length;

  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5">
      <JapaneseProgressHeader
        currentLevel={focusedGroup.level.officialLabel}
        startedLevels={startedLevels}
        totalCompletedWords={totalCompletedWords}
        totalWords={totalWords}
      />
      <JapaneseLevelSummary
        focusedLevelIndex={focusedLevelIndex}
        groups={groups}
      />
      <FocusedLevelDetail
        levelLabel={focusedGroup.level.officialLabel}
        completedWords={focusedGroup.completedWords}
        totalWords={focusedGroup.totalWords}
        rows={focusedGroup.rows}
      />
    </div>
  );
}

function ReleasedCourseCard(props: {
  href: string;
  name: string;
}) {
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

function ComingSoonCourseList() {
  const upcomingCourses = dashboardCourses.filter((course) => !isCourseReleased(course.slug));

  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.03] p-5">
      <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
        Coming next
      </p>
      <div className="mt-4 flex flex-wrap gap-3">
        {upcomingCourses.map((course) => (
          <span
            key={course.slug}
            className="rounded-full border border-white/10 bg-black/20 px-4 py-2 text-sm text-stone-300"
          >
            {course.name}
          </span>
        ))}
      </div>
    </div>
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
      <div className="mt-8">
        <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
          Course access
        </p>
        <div className="mt-4 grid gap-4 lg:grid-cols-[1.2fr_0.8fr]">
          <div className="grid gap-4">
            {dashboardCourses
              .filter((course) => isCourseReleased(course.slug))
              .map((course) => (
                <ReleasedCourseCard
                  key={course.slug}
                  href={`/dashboard/${course.slug}`}
                  name={course.name}
                />
              ))}
          </div>
          <ComingSoonCourseList />
        </div>
      </div>
    </section>
  );
}
