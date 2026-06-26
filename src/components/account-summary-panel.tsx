"use client";

import Link from "next/link";
import { dashboardCourses } from "@/lib/product-content";
import { useCourseCertificates } from "@/components/use-course-certificates";

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

function CourseAccessCard(props: { href: string; name: string }) {
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
  const certificates = useCourseCertificates();

  return (
    <section className="rounded-[2rem] border border-white/10 bg-white/[0.045] p-7">
      <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
        Learning account
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
        Free access and saved progress
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-8 text-stone-300">
        All courses stay free. Your account keeps track of course access, ongoing progress, and every certificate you earn.
      </p>
      <div className="mt-8 grid gap-4 lg:grid-cols-3">
        <SummaryMetric label="Course access" value="All free" />
        <SummaryMetric label="Available paths" value={String(dashboardCourses.length)} />
        <SummaryMetric label="Certificates earned" value={String(certificates.certificates.length)} />
      </div>
      <div className="mt-8 grid gap-4 lg:grid-cols-3">
        {dashboardCourses.map((course) => (
          <CourseAccessCard
            key={course.slug}
            href={`/dashboard/${course.slug}`}
            name={course.name}
          />
        ))}
      </div>
    </section>
  );
}
