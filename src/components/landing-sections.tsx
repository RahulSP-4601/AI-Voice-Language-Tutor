import Link from "next/link";
import {
  landingComparison,
  landingHeroStats,
  landingLanguages,
  landingSteps,
  landingTestimonials,
  processHighlights,
} from "@/lib/product-content";

function LandingNav() {
  return (
    <nav className="mb-9 flex items-center justify-between rounded-full border border-white/10 bg-white/5 px-5 py-3 backdrop-blur">
      <p className="text-xs uppercase tracking-[0.4em] text-amber-200">
        AI Voice Tutor
      </p>
      <div className="flex items-center gap-3 text-sm text-stone-300">
        <Link href="#courses" className="transition hover:text-white">
          Courses
        </Link>
        <Link
          href="/auth"
          className="rounded-full border border-white/15 px-4 py-2 transition hover:border-amber-200/60 hover:text-white"
        >
          Google Login
        </Link>
      </div>
    </nav>
  );
}

function HeroCopy() {
  return (
    <div className="space-y-6">
      <div className="inline-flex items-center gap-2 rounded-full border border-amber-300/20 bg-amber-300/10 px-4 py-2 text-xs text-amber-100 sm:text-sm">
        <span className="h-2 w-2 rounded-full bg-amber-300 shadow-[0_0_20px_rgba(252,211,77,0.85)]" />
        Start from zero. Speak with AI. Get certified.
      </div>
      <div className="max-w-4xl space-y-5">
        <h1 className="max-w-4xl text-4xl font-semibold tracking-[-0.05em] text-white sm:text-5xl lg:text-7xl">
          Language learning that finally feels like a premium speaking coach.
        </h1>
        <p className="max-w-2xl text-base leading-8 text-stone-300 sm:text-lg">
          Practice live with an AI tutor, build real speaking confidence, and
          move through structured language lessons designed around speaking
          first.
        </p>
      </div>
    </div>
  );
}

function HeroActions() {
  return (
    <div className="flex flex-col gap-4 sm:flex-row">
      <Link
        href="/auth"
        className="rounded-full bg-[linear-gradient(135deg,#f7c874_0%,#ff8c69_100%)] px-6 py-3.5 text-center text-sm font-semibold text-slate-950 transition duration-300 hover:scale-[1.02] hover:shadow-[0_24px_60px_rgba(255,150,95,0.35)] sm:text-base"
      >
        Start Free with Basic 1
      </Link>
      <Link
        href="#courses"
        className="rounded-full border border-white/15 bg-white/5 px-6 py-3.5 text-center text-sm font-medium text-white transition hover:border-white/35 hover:bg-white/10 sm:text-base"
      >
        See Courses
      </Link>
    </div>
  );
}

function HeroStats() {
  return (
    <div className="grid gap-4 text-xs text-stone-300 sm:grid-cols-3 sm:text-sm">
      {landingHeroStats.map((stat) => (
        <div
          key={stat.label}
          className="rounded-3xl border border-white/10 bg-white/5 p-4"
        >
          <p className="text-2xl font-semibold text-white sm:text-3xl">{stat.value}</p>
          <p className="mt-2">{stat.label}</p>
        </div>
      ))}
    </div>
  );
}

function SessionCard() {
  return (
    <div className="rounded-[1.6rem] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.09),rgba(255,255,255,0.03))] p-4 sm:p-5">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.35em] text-amber-200">
            Voice Session
          </p>
          <h2 className="mt-3 text-xl font-semibold text-white sm:text-2xl">
            Japanese Basic 1
          </h2>
          <p className="mt-2 max-w-xs text-sm leading-6 text-stone-300">
            Your AI tutor is guiding pronunciation, confidence, and repetition
            in one flow.
          </p>
        </div>
        <div className="rounded-full border border-emerald-300/25 bg-emerald-300/10 px-3 py-1 text-xs text-emerald-200">
          Live feedback
        </div>
      </div>
      <div className="mt-6 grid gap-4">
        <div className="rounded-2xl bg-[#111817] p-4">
          <p className="text-xs uppercase tracking-[0.3em] text-stone-500">
            AI Tutor
          </p>
          <p className="mt-2 text-base text-white sm:text-lg">
            Repeat after me: <span className="text-amber-200">Arigatou</span>
          </p>
        </div>
        <div className="rounded-2xl border border-amber-300/15 bg-amber-200/5 p-4">
          <p className="text-xs uppercase tracking-[0.3em] text-stone-500">
            Feedback
          </p>
          <p className="mt-2 text-sm leading-6 text-stone-200">
            Meaning was correct. Slow down the last syllable and keep the
            middle vowel open. Try once more for a cleaner score.
          </p>
        </div>
        <div className="grid gap-4 sm:grid-cols-3">
          <MetricCard label="Pronunciation" value="89%" />
          <MetricCard label="Confidence" value="92%" />
          <MetricCard label="Certificate" value="Ready" />
        </div>
      </div>
    </div>
  );
}

function MetricCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/4 p-4">
      <p className="text-xs uppercase tracking-[0.25em] text-stone-500">
        {label}
      </p>
      <p className="mt-2 text-xl font-semibold text-white sm:text-2xl">{value}</p>
    </div>
  );
}

function HeroVisual() {
  return (
    <div className="relative">
      <div className="pointer-events-none absolute inset-0 animate-[pulse_5s_ease-in-out_infinite] rounded-[2rem] bg-[radial-gradient(circle_at_top,rgba(247,200,116,0.18),transparent_58%)]" />
      <div className="relative rotate-[-2deg] rounded-[2rem] border border-white/10 bg-[#0c1010]/90 p-5 shadow-[0_30px_100px_rgba(0,0,0,0.45)] backdrop-blur">
        <SessionCard />
      </div>
    </div>
  );
}

export function HeroSection() {
  return (
    <section className="relative overflow-hidden px-6 pb-16 pt-8 sm:px-10 lg:px-14">
      <div className="absolute inset-x-0 top-[-20rem] h-[34rem] bg-[radial-gradient(circle,rgba(255,188,87,0.24),transparent_55%)] blur-3xl" />
      <div className="absolute right-[-10rem] top-28 h-72 w-72 rounded-full bg-emerald-400/12 blur-3xl" />
      <div className="mx-auto max-w-7xl">
        <LandingNav />
        <div className="grid gap-8 lg:grid-cols-[1.05fr_0.95fr] lg:items-center">
          <div className="space-y-7">
            <HeroCopy />
            <HeroActions />
            <HeroStats />
          </div>
          <HeroVisual />
        </div>
      </div>
    </section>
  );
}

function SectionHeading(props: {
  eyebrow: string;
  title: string;
  body: string;
  className?: string;
}) {
  return (
    <div className={props.className}>
      <p className="text-sm uppercase tracking-[0.35em] text-amber-200">
        {props.eyebrow}
      </p>
      <h2 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white sm:text-4xl">
        {props.title}
      </h2>
      <p className="mt-4 text-sm leading-7 text-stone-300 sm:text-base sm:leading-8">
        {props.body}
      </p>
    </div>
  );
}

function LanguageCard({
  name,
  promise,
  script,
}: {
  name: string;
  promise: string;
  script: string;
}) {
  return (
    <article className="group rounded-[1.75rem] border border-white/10 bg-white/[0.045] p-5 transition duration-300 hover:-translate-y-1 hover:border-white/20 hover:bg-white/[0.08]">
      <div className="mb-6 inline-flex rounded-full border border-amber-300/20 bg-amber-300/10 px-3 py-1 text-xs uppercase tracking-[0.28em] text-amber-100">
        {script}
      </div>
      <h3 className="text-2xl font-semibold text-white">{name}</h3>
      <p className="mt-3 text-sm leading-7 text-stone-300">{promise}</p>
      <div className="mt-8 space-y-3 text-sm text-stone-200">
        <DetailRow label="Course access" value="Free" valueClassName="text-emerald-200" />
        <DetailRow label="Lesson format" value="Voice-first" />
        <DetailRow label="Total levels" value="5" />
      </div>
    </article>
  );
}

function DetailRow({
  label,
  value,
  valueClassName,
}: {
  label: string;
  value: string;
  valueClassName?: string;
}) {
  return (
    <div className="flex items-center justify-between rounded-2xl bg-black/20 px-4 py-3">
      <span>{label}</span>
      <span className={`font-medium text-white ${valueClassName ?? ""}`}>
        {value}
      </span>
    </div>
  );
}

export function LanguagesSection() {
  return (
    <section id="courses" className="px-6 py-18 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl">
        <SectionHeading
          className="mb-8 max-w-2xl"
          eyebrow="Language Paths"
          title="Browse every language and start learning right away."
          body="Every path begins with a structured foundation level built around speaking, listening, and guided repetition."
        />
        <div className="grid gap-5 lg:grid-cols-5">
          {landingLanguages.map((language) => (
            <LanguageCard key={language.name} {...language} />
          ))}
        </div>
      </div>
    </section>
  );
}

function StepCard({
  description,
  index,
  title,
}: {
  description: string;
  index: number;
  title: string;
}) {
  return (
    <div className="rounded-[1.75rem] border border-white/10 bg-white/[0.045] p-6">
      <div className="flex items-start gap-4">
        <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-200 text-lg font-semibold text-slate-950">
          {index}
        </div>
        <div>
          <h3 className="text-xl font-semibold text-white">{title}</h3>
          <p className="mt-3 text-sm leading-7 text-stone-300">{description}</p>
        </div>
      </div>
    </div>
  );
}

function ProcessOverview() {
  return (
    <div className="rounded-[1.75rem] border border-white/10 bg-white/[0.04] p-5">
      <p className="text-xs uppercase tracking-[0.3em] text-emerald-200">
        Why this flow works
      </p>
      <div className="mt-4 space-y-3">
        {processHighlights.map((item) => (
          <div
            key={item}
            className="flex items-start gap-3 rounded-2xl border border-white/6 bg-black/15 px-4 py-3"
          >
            <span className="mt-1.5 h-2 w-2 rounded-full bg-amber-300" />
            <p className="text-sm leading-6 text-stone-200">{item}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export function ProcessSection() {
  return (
    <section className="px-6 py-18 sm:px-10 lg:px-14">
      <div className="mx-auto grid max-w-7xl gap-10 lg:grid-cols-[0.9fr_1.1fr]">
        <div className="max-w-xl space-y-6">
          <SectionHeading
            eyebrow="How It Works"
            title="A clean funnel from premium first impression to live language practice."
            body="We lead with a premium first impression, then move learners directly into guided speaking sessions so the value feels real fast."
          />
          <ProcessOverview />
        </div>
        <div className="grid gap-4">
          {landingSteps.map((step, index) => (
            <StepCard
              key={step.title}
              index={index + 1}
              title={step.title}
              description={step.description}
            />
          ))}
        </div>
      </div>
    </section>
  );
}

function ComparisonCard({
  description,
  title,
}: {
  description: string;
  title: string;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/8 bg-black/20 p-5">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-white">{title}</h3>
        <span className="rounded-full border border-emerald-300/20 bg-emerald-300/10 px-3 py-1 text-xs uppercase tracking-[0.2em] text-emerald-200">
          Better
        </span>
      </div>
      <p className="mt-3 text-sm leading-7 text-stone-300">{description}</p>
    </div>
  );
}

export function ComparisonSection() {
  return (
    <section className="px-6 py-18 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl rounded-[2rem] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.08),rgba(255,255,255,0.03))] p-8 shadow-[0_30px_90px_rgba(0,0,0,0.24)]">
        <div className="grid gap-8 lg:grid-cols-2">
          <div>
            <p className="text-sm uppercase tracking-[0.35em] text-amber-200">
              Why We Win
            </p>
            <h2 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
              Not another flashcard app. A speaking product with outcome energy.
            </h2>
          </div>
          <div className="grid gap-4">
            {landingComparison.map((item) => (
              <ComparisonCard key={item.title} {...item} />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function TestimonialCard({
  name,
  quote,
  role,
}: {
  name: string;
  quote: string;
  role: string;
}) {
  return (
    <blockquote className="rounded-[1.75rem] border border-white/10 bg-white/[0.045] p-6">
      <p className="text-base leading-8 text-stone-200">“{quote}”</p>
      <footer className="mt-6">
        <p className="font-semibold text-white">{name}</p>
        <p className="text-sm text-stone-400">{role}</p>
      </footer>
    </blockquote>
  );
}

export function SocialProofSection() {
  return (
    <section className="px-6 py-18 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl">
        <SectionHeading
          className="mb-8 max-w-2xl"
          eyebrow="Premium Feel"
          title="The first phase already needs to feel investable."
          body="We want the product to look like a real modern education business from the first click, not a placeholder app waiting for later polish."
        />
        <div className="grid gap-5 lg:grid-cols-3">
          {landingTestimonials.map((item) => (
            <TestimonialCard key={item.name} {...item} />
          ))}
        </div>
      </div>
    </section>
  );
}

export function FinalCtaSection() {
  return (
    <section className="px-6 pb-20 pt-10 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl rounded-[2rem] border border-amber-300/15 bg-[linear-gradient(135deg,rgba(247,200,116,0.16),rgba(24,36,34,0.9))] p-8 shadow-[0_30px_90px_rgba(0,0,0,0.24)]">
        <div className="grid gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
          <div>
            <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
              Launch Funnel
            </p>
            <h2 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
              Free access first. Real speaking practice from the first session.
            </h2>
            <p className="mt-4 max-w-2xl text-base leading-8 text-stone-200">
              Start with Google login, let the user test the voice tutor in
              Basic 1, then bring them into the dashboard and course runner to
              keep learning.
            </p>
          </div>
          <div className="flex flex-col gap-4">
            <Link
              href="/auth"
              className="rounded-full bg-slate-950 px-7 py-4 text-center text-base font-semibold text-white transition hover:bg-black"
            >
              Continue to Google Signup
            </Link>
            <Link
              href="/dashboard"
              className="rounded-full border border-white/15 bg-white/5 px-7 py-4 text-center text-base font-medium text-white transition hover:border-white/30 hover:bg-white/10"
            >
              Preview Dashboard
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}
