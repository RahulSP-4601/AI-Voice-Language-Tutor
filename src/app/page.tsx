import { EnvironmentStatus } from "@/components/environment-status";
import { FeatureCard } from "@/components/feature-card";

const features = [
  {
    title: "Frontend and backend together",
    description:
      "Build the product in one Next.js App Router codebase with routes for UI, APIs, and server work.",
  },
  {
    title: "Supabase-ready data layer",
    description:
      "Environment-safe helpers keep the client lazy so builds do not crash when secrets are missing.",
  },
  {
    title: "Guardian before every commit",
    description:
      "Static and functional checks run in pre-commit and stop risky commits before they land.",
  },
];

export default function Home() {
  return (
    <main className="min-h-screen bg-[radial-gradient(circle_at_top,#154734_0%,#08110d_48%,#040706_100%)] text-stone-100">
      <section className="mx-auto flex min-h-screen max-w-6xl flex-col justify-center gap-10 px-6 py-20">
        <div className="max-w-3xl space-y-6">
          <p className="text-sm uppercase tracking-[0.4em] text-emerald-300">
            AI Voice Tutor
          </p>
          <h1 className="text-5xl font-semibold tracking-tight text-white sm:text-7xl">
            A Next.js starter with Supabase and a commit guardian built in.
          </h1>
          <p className="max-w-2xl text-lg leading-8 text-stone-300">
            This starter gives you a clean App Router setup, a safe Supabase
            integration layer, and pre-commit automation that blocks oversized
            files, long functions, lint issues, type errors, and broken builds.
          </p>
        </div>
        <EnvironmentStatus />
        <div className="grid gap-4 md:grid-cols-3">
          {features.map((feature) => (
            <FeatureCard key={feature.title} {...feature} />
          ))}
        </div>
      </section>
    </main>
  );
}
