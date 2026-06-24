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

export function CourseHero(props: {
  activeSlug: DashboardCourseSlug;
}) {
  const course = dashboardCourses.find((item) => item.slug === props.activeSlug);

  if (!course) {
    return null;
  }

  return (
    <section className="rounded-[2rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
      <div className="grid gap-8 lg:grid-cols-[1.05fr_0.95fr] lg:items-center">
        <CourseHeroCopy
          badge={course.badge}
          name={course.name}
          description={course.description}
        />
        <CourseHeroStats
          currentLevel={course.currentLevel}
          statusNote={course.statusNote}
          bundleStatus={course.bundleStatus}
          bundleNote={course.bundleNote}
        />
      </div>
      <div className="mt-8 grid gap-4 lg:grid-cols-3">
        <DetailRow label="Certificate path" value={course.certificateState} />
        <DetailRow label="Bundle price" value="$80" />
        <DetailRow label="Next lesson" value={course.nextLesson} />
      </div>
    </section>
  );
}

function CourseHeroCopy(props: {
  badge: string;
  description: string;
  name: string;
}) {
  return (
    <div>
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        {props.badge}
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
        {props.name} course dashboard
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-8 text-stone-200">
        {props.description}
      </p>
    </div>
  );
}

function HeroStatCard(props: {
  label: string;
  note: string;
  value: string;
}) {
  return (
    <div className="rounded-[1.5rem] bg-black/25 p-5">
      <p className="text-sm uppercase tracking-[0.25em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-3 text-2xl font-semibold text-white">{props.value}</p>
      <p className="mt-2 text-sm text-stone-300">{props.note}</p>
    </div>
  );
}

function CourseHeroStats(props: {
  bundleNote: string;
  bundleStatus: string;
  currentLevel: string;
  statusNote: string;
}) {
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <HeroStatCard
        label="Current level"
        value={props.currentLevel}
        note={props.statusNote}
      />
      <HeroStatCard
        label="Bundle status"
        value={props.bundleStatus}
        note={props.bundleNote}
      />
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
