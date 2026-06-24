import Link from "next/link";
import { dashboardPhaseItems, dashboardTracks } from "@/lib/product-content";

function SummaryCard({
  label,
  title,
  subtitle,
}: {
  label: string;
  subtitle: string;
  title: string;
}) {
  return (
    <div className="rounded-[1.5rem] bg-black/25 p-5">
      <p className="text-sm uppercase tracking-[0.25em] text-stone-400">
        {label}
      </p>
      <p className="mt-3 text-2xl font-semibold text-white">{title}</p>
      <p className="mt-2 text-sm text-stone-300">{subtitle}</p>
    </div>
  );
}

export function DashboardHeader() {
  return (
    <section className="rounded-[2rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.16),rgba(255,255,255,0.03))] p-8 shadow-[0_30px_90px_rgba(0,0,0,0.24)]">
      <div className="grid gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
        <div>
          <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
            Dashboard Preview
          </p>
          <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
            A calm home base after Google login.
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-8 text-stone-200">
            The dashboard is intentionally simple in phase one: current path,
            recent progress, and a clear next move into the free Basic 1 course.
          </p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          <SummaryCard
            label="Current Track"
            title="Japanese"
            subtitle="Basic 1 is ready to start."
          />
          <SummaryCard
            label="Bundle Status"
            title="Free Track"
            subtitle="$80 upsell comes later."
          />
        </div>
      </div>
    </section>
  );
}

function TrackStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between rounded-2xl bg-black/20 px-4 py-3 text-stone-200">
      <span>{label}</span>
      <span className="font-medium text-white">{value}</span>
    </div>
  );
}

function TrackCard({
  name,
  stats,
  status,
  summary,
}: {
  name: string;
  stats: readonly { label: string; value: string }[];
  status: string;
  summary: string;
}) {
  return (
    <article className="rounded-[1.75rem] border border-white/10 bg-white/[0.045] p-6 transition hover:border-white/20 hover:bg-white/[0.08]">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-semibold text-white">{name}</h2>
        <span className="rounded-full border border-emerald-300/20 bg-emerald-300/10 px-3 py-1 text-xs uppercase tracking-[0.2em] text-emerald-200">
          {status}
        </span>
      </div>
      <p className="mt-4 text-sm leading-7 text-stone-300">{summary}</p>
      <div className="mt-6 space-y-3 text-sm">
        {stats.map((stat) => (
          <TrackStat key={stat.label} {...stat} />
        ))}
      </div>
    </article>
  );
}

export function DashboardTrackGrid() {
  return (
    <section className="grid gap-5 lg:grid-cols-3">
      {dashboardTracks.map((track) => (
        <TrackCard key={track.name} {...track} />
      ))}
    </section>
  );
}

function NextStepCard() {
  return (
    <div className="rounded-[1.75rem] border border-white/10 bg-white/[0.045] p-6">
      <p className="text-sm uppercase tracking-[0.3em] text-amber-200">
        Next Recommended Step
      </p>
      <h2 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white">
        Start Japanese Basic 1 and earn the first free certificate.
      </h2>
      <p className="mt-4 max-w-2xl text-sm leading-8 text-stone-300">
        In this phase, the dashboard guides users toward one obvious action.
        They should never wonder what to do after login.
      </p>
      <div className="mt-8 flex flex-col gap-4 sm:flex-row">
        <Link
          href="/auth"
          className="rounded-full bg-[linear-gradient(135deg,#f7c874_0%,#ff8c69_100%)] px-6 py-3 text-center font-semibold text-slate-950 transition hover:scale-[1.01]"
        >
          Connect Google
        </Link>
        <Link
          href="/"
          className="rounded-full border border-white/15 bg-white/5 px-6 py-3 text-center font-medium text-white transition hover:border-white/30 hover:bg-white/10"
        >
          Back to Landing Page
        </Link>
      </div>
    </div>
  );
}

function PhaseOneCard() {
  return (
    <div className="rounded-[1.75rem] border border-white/10 bg-[#0c1214] p-6">
      <p className="text-sm uppercase tracking-[0.3em] text-emerald-200">
        Included In Phase One
      </p>
      <div className="mt-6 space-y-4">
        {dashboardPhaseItems.map((item) => (
          <div
            key={item}
            className="flex items-start gap-3 rounded-2xl border border-white/6 bg-white/[0.03] px-4 py-3"
          >
            <span className="mt-1 h-2.5 w-2.5 rounded-full bg-emerald-300" />
            <p className="text-sm leading-7 text-stone-200">{item}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export function DashboardNextStep() {
  return (
    <section className="grid gap-5 lg:grid-cols-[1fr_0.95fr]">
      <NextStepCard />
      <PhaseOneCard />
    </section>
  );
}
