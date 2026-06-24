import { hasSupabaseEnv } from "@/lib/supabase/env";

export function EnvironmentStatus() {
  const configured = hasSupabaseEnv();
  const badgeClassName = configured
    ? "border-emerald-400/40 bg-emerald-400/10 text-emerald-200"
    : "border-amber-400/40 bg-amber-400/10 text-amber-100";

  return (
    <section className="max-w-3xl rounded-3xl border border-white/10 bg-black/20 p-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="space-y-2">
          <p className="text-sm uppercase tracking-[0.3em] text-stone-400">
            Backend readiness
          </p>
          <h2 className="text-2xl font-semibold text-white">
            Supabase environment check
          </h2>
          <p className="text-sm leading-7 text-stone-300">
            Add your project URL and anon key to <code>.env.local</code> and
            the data layer will be ready for routes, actions, and auth work.
          </p>
        </div>
        <div
          className={`inline-flex rounded-full border px-4 py-2 text-sm font-medium ${badgeClassName}`}
        >
          {configured ? "Connected to env configuration" : "Missing env values"}
        </div>
      </div>
    </section>
  );
}
