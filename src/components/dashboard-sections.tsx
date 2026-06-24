import Link from "next/link";
import { dashboardCourses, type DashboardCourseSlug } from "@/lib/product-content";
import { DashboardAccountMenu } from "@/components/dashboard-account-menu";

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
        {dashboardCourses.map((course) => (
          <Link
            key={course.slug}
            href={getCourseHref(course.slug)}
            className={`rounded-full border px-4 py-2 text-sm font-medium transition ${tabClassName(
              props.activeSlug === course.slug,
            )}`}
          >
            {course.name}
          </Link>
        ))}
      </div>
    </section>
  );
}

function OverviewCourseCard(props: {
  description: string;
  name: string;
  slug: DashboardCourseSlug;
}) {
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

function DetailRow(props: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between rounded-2xl bg-black/20 px-4 py-3 text-sm text-stone-200">
      <span>{props.label}</span>
      <span className="font-medium text-white">{props.value}</span>
    </div>
  );
}

export function CourseWorkspace(props: {
  activeSlug: DashboardCourseSlug;
}) {
  const course = dashboardCourses.find((item) => item.slug === props.activeSlug);

  if (!course) {
    return null;
  }

  return (
    <section className="grid gap-6 lg:grid-cols-[0.3fr_0.7fr]">
      <CourseLevelSidebar
        framework={course.officialFramework}
        levels={course.levels}
        courseName={course.name}
      />
      <CourseDisplayPanel course={course} />
    </section>
  );
}

function CourseLevelSidebar(props: {
  courseName: string;
  framework: string;
  levels: readonly { completed: boolean; name: string; summary: string }[];
}) {
  return (
    <aside className="rounded-[1.9rem] border border-white/10 bg-white/[0.04] p-5">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.courseName}
      </p>
      <p className="mt-2 text-sm text-stone-400">{props.framework} levels</p>
      <div className="mt-6 space-y-3">
        {props.levels.map((level) => (
          <LevelRow key={level.name} {...level} />
        ))}
      </div>
    </aside>
  );
}

function LevelRow(props: {
  completed: boolean;
  name: string;
  summary: string;
}) {
  return (
    <div className="flex items-start gap-3 rounded-[1.3rem] border border-white/8 bg-black/20 px-4 py-3">
      <span
        className={`mt-0.5 flex h-6 w-6 items-center justify-center rounded-full text-xs font-semibold ${
          props.completed
            ? "bg-emerald-300 text-slate-950"
            : "border border-white/15 bg-white/[0.04] text-stone-400"
        }`}
      >
        {props.completed ? "✓" : ""}
      </span>
      <div>
        <p className="text-sm font-medium text-white">{props.name}</p>
        <p className="mt-1 text-xs leading-6 text-stone-400">{props.summary}</p>
      </div>
    </div>
  );
}

function CourseDisplayPanel(props: {
  course: (typeof dashboardCourses)[number];
}) {
  return (
    <div className="rounded-[1.9rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.course.name} course
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
        {props.course.currentLevel}
      </h1>
      <p className="mt-4 max-w-3xl text-base leading-8 text-stone-200">
        {props.course.description}
      </p>
      <div className="mt-8 grid gap-4 lg:grid-cols-3">
        <DetailRow label="Certificate path" value={props.course.certificateState} />
        <DetailRow label="Bundle price" value="$80" />
        <DetailRow label="Next lesson" value={props.course.nextLesson} />
      </div>
    </div>
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
        Purchased courses
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
        Account and purchases
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-8 text-stone-300">
        Paid course bundles will appear here after checkout. Free access can
        continue normally even when no paid bundle has been purchased yet.
      </p>
      <div className="mt-8 grid gap-4">
        <PurchasedCourseCard name="Japanese Bundle" status="Not purchased" />
        <PurchasedCourseCard name="English Bundle" status="Not purchased" />
        <PurchasedCourseCard name="German Bundle" status="Not purchased" />
      </div>
    </section>
  );
}
