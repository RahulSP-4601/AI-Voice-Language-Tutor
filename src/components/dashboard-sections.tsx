import Link from "next/link";
import { dashboardCourses, type DashboardCourseSlug } from "@/lib/product-content";
import { DashboardAccountMenu } from "@/components/dashboard-account-menu";
import {
  getCourseAvailabilityLabel,
  isCourseReleased,
} from "@/lib/course-presentation";
export { CourseWorkspace } from "@/components/course-workspace";

function DashboardBrand() {
  return (
    <div>
      <p className="text-xs uppercase tracking-[0.35em] text-amber-200">
        AI Voice Language Tutor
      </p>
      <p className="mt-2 text-sm text-stone-400">
        Voice-first learning dashboard
      </p>
    </div>
  );
}

export function DashboardTopBar() {
  return (
    <header className="flex flex-col gap-4 rounded-[1.75rem] border border-white/10 bg-white/[0.04] px-5 py-4 backdrop-blur sm:flex-row sm:items-center sm:justify-between">
      <DashboardBrand />
      <DashboardAccountMenu />
    </header>
  );
}

function tabClassName(isActive: boolean) {
  if (isActive) {
    return "border-emerald-300/30 bg-emerald-300/12 text-emerald-100";
  }

  return "border-white/10 bg-white/[0.04] text-stone-300 hover:border-white/18 hover:text-white";
}

function getCourseHref(slug: DashboardCourseSlug) {
  return `/dashboard/${slug}`;
}

export function DashboardCourseTabs(props: {
  activeSlug?: DashboardCourseSlug;
}) {
  return (
    <section className="overflow-x-auto">
      <div className="flex min-w-max gap-3">
        {dashboardCourses.map((course) =>
          isCourseReleased(course.slug) ? (
            <Link
              key={course.slug}
              href={getCourseHref(course.slug)}
              className={`rounded-full border px-4 py-2 text-sm font-medium transition ${tabClassName(
                props.activeSlug === course.slug,
              )}`}
            >
              {course.name}
            </Link>
          ) : (
            <span
              key={course.slug}
              className="rounded-full border border-white/10 bg-white/[0.03] px-4 py-2 text-sm font-medium text-stone-500"
            >
              {course.name} · Coming soon
            </span>
          )
        )}
      </div>
    </section>
  );
}

function OverviewCourseCard(props: {
  description: string;
  name: string;
  slug: DashboardCourseSlug;
}) {
  const available = isCourseReleased(props.slug);

  if (!available) {
    return (
      <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.03] p-5 opacity-80">
        <div className="flex items-start justify-between gap-4">
          <p className="text-lg font-semibold text-white">{props.name}</p>
          <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.22em] text-stone-400">
            {getCourseAvailabilityLabel(props.slug)}
          </span>
        </div>
        <p className="mt-3 text-sm leading-7 text-stone-400">
          This course is locked right now. {props.description}
        </p>
        <div className="mt-5 inline-flex rounded-full border border-white/10 bg-white/[0.03] px-3 py-1 text-xs uppercase tracking-[0.22em] text-stone-400">
          Coming soon
        </div>
      </div>
    );
  }

  return (
    <Link
      href={getCourseHref(props.slug)}
      className="rounded-[1.5rem] border border-white/10 bg-white/[0.045] p-5 transition hover:-translate-y-0.5 hover:border-white/20 hover:bg-white/[0.08]"
    >
      <p className="text-lg font-semibold text-white">{props.name}</p>
      <p className="mt-3 text-sm leading-7 text-stone-300">
        {props.description}
      </p>
      <div className="mt-5 inline-flex rounded-full border border-amber-300/20 bg-amber-300/10 px-3 py-1 text-xs uppercase tracking-[0.22em] text-amber-100">
        Open course
      </div>
    </Link>
  );
}

export function DashboardOverview() {
  return (
    <section>
      <div className="mb-6">
        <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
          Select a course
        </p>
      </div>
      <div className="grid gap-4 lg:grid-cols-5">
        {dashboardCourses.map((course) => (
          <OverviewCourseCard
            key={course.slug}
            slug={course.slug}
            name={course.name}
            description={course.description}
          />
        ))}
      </div>
    </section>
  );
}

export function CourseComingSoonPanel(props: {
  slug: DashboardCourseSlug;
}) {
  const course = dashboardCourses.find((item) => item.slug === props.slug);

  if (!course) {
    return null;
  }

  return (
    <section className="space-y-8">
      <DashboardCourseTabs activeSlug={props.slug} />
      <div className="rounded-[1.75rem] border border-white/10 bg-white/[0.04] p-6">
        <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
          Coming soon
        </p>
        <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
          {course.name} lessons are not live yet.
        </h1>
        <p className="mt-4 max-w-3xl text-base leading-8 text-stone-300">
          Japanese is the only unlocked course right now. We&apos;ll open the{" "}
          {course.name} path once its lesson content, tutor playback, and
          evaluation flow are ready for learners.
        </p>
      </div>
    </section>
  );
}

function PurchasedCourseCard(props: {
  name: string;
  status: string;
}) {
  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5">
      <div className="flex items-center justify-between gap-4">
        <p className="text-lg font-semibold text-white">{props.name}</p>
        <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-xs uppercase tracking-[0.2em] text-stone-300">
          {props.status}
        </span>
      </div>
    </div>
  );
}

export function AccountSummary() {
  return (
    <section className="rounded-[2rem] border border-white/10 bg-white/[0.045] p-7">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        Learning account
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
        Progress and course access
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-8 text-stone-300">
        All available courses are free. This area can track your active
        languages, completed modules, and later certificates in one place.
      </p>
      <div className="mt-8 grid gap-4">
        <PurchasedCourseCard name="Japanese course" status="Available" />
        <PurchasedCourseCard name="English course" status="Available" />
        <PurchasedCourseCard name="German course" status="Available" />
      </div>
    </section>
  );
}
