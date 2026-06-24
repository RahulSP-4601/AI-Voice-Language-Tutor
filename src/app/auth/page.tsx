import { AuthCard } from "@/components/auth-card";

export default function AuthPage() {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#081010_0%,#071718_100%)] px-6 py-10 text-stone-100 sm:px-10 lg:px-14">
      <div className="mx-auto grid min-h-[calc(100vh-5rem)] max-w-7xl gap-12 lg:grid-cols-[1fr_0.9fr] lg:items-center">
        <section className="max-w-2xl">
          <p className="text-sm uppercase tracking-[0.35em] text-emerald-200">
            Google Auth Entry
          </p>
          <h1 className="mt-4 text-5xl font-semibold tracking-[-0.05em] text-white sm:text-6xl">
            Start with one clean login, then step into your first speaking path.
          </h1>
          <p className="mt-6 text-lg leading-8 text-stone-300">
            This first phase keeps the journey focused: premium landing page,
            Google signup or login, then a simple dashboard users can grow into.
          </p>
          <div className="mt-10 grid gap-4 sm:grid-cols-3">
            <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.05] p-5">
              <p className="text-sm uppercase tracking-[0.25em] text-stone-400">
                Step 01
              </p>
              <p className="mt-3 text-lg font-semibold text-white">Google auth</p>
            </div>
            <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.05] p-5">
              <p className="text-sm uppercase tracking-[0.25em] text-stone-400">
                Step 02
              </p>
              <p className="mt-3 text-lg font-semibold text-white">Profile capture</p>
            </div>
            <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.05] p-5">
              <p className="text-sm uppercase tracking-[0.25em] text-stone-400">
                Step 03
              </p>
              <p className="mt-3 text-lg font-semibold text-white">Dashboard entry</p>
            </div>
          </div>
        </section>
        <AuthCard />
      </div>
    </main>
  );
}
