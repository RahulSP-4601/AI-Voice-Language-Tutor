import { dashboardTracks } from "@/lib/product-content";

function DashboardTopBar() {
  return (
    <header className="flex flex-col gap-4 rounded-[1.75rem] border border-white/10 bg-white/[0.04] px-5 py-4 backdrop-blur sm:flex-row sm:items-center sm:justify-between">
      <div>
        <p className="text-xs uppercase tracking-[0.35em] text-amber-200">
          AI Voice Language Tutor
        </p>
        <p className="mt-2 text-sm text-stone-400">
          Voice-first learning dashboard
        </p>
      </div>
      <button
        type="button"
        className="flex items-center gap-3 self-start rounded-full border border-white/12 bg-black/20 px-3 py-2 text-left transition hover:border-white/20 hover:bg-black/30 sm:self-auto"
      >
        <span className="flex h-10 w-10 items-center justify-center rounded-full bg-[linear-gradient(135deg,#8f9cf9_0%,#d0d5ff_100%)] text-sm font-semibold text-slate-950">
          RP
        </span>
        <span>
          <span className="block text-sm font-medium text-white">
            Rahul Panchal
          </span>
          <span className="block text-xs text-stone-400">
            My account details
          </span>
        </span>
        <span className="text-stone-400">▾</span>
      </button>
    </header>
  );
}

function LanguageTabs() {
  return (
    <section className="overflow-x-auto">
      <div className="flex min-w-max gap-3">
        {dashboardTracks.map((track) => (
          <button
            key={track.name}
            type="button"
            className={`rounded-full border px-4 py-2 text-sm font-medium transition ${
              track.status === "Active"
                ? "border-emerald-300/30 bg-emerald-300/12 text-emerald-100"
                : "border-white/10 bg-white/[0.04] text-stone-300 hover:border-white/18 hover:text-white"
            }`}
          >
            {track.name}
          </button>
        ))}
      </div>
    </section>
  );
}

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
    <div className="space-y-5">
      <DashboardTopBar />
      <LanguageTabs />
      <section className="rounded-[2rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.16),rgba(255,255,255,0.03))] p-8 shadow-[0_30px_90px_rgba(0,0,0,0.24)]">
        <div className="grid gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
          <div>
            <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
              Dashboard
            </p>
            <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white sm:text-5xl">
              Your language tracks, progress, and account in one place.
            </h1>
            <p className="mt-4 max-w-2xl text-base leading-8 text-stone-200">
              Keep every course language visible, highlight the current active
              path, and make account access obvious in the top-right corner.
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
    </div>
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
