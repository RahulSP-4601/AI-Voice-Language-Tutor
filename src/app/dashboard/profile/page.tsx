import { DashboardCourseTabs, DashboardTopBar } from "@/components/dashboard-sections";

function DetailCard(props: { label: string; value: string }) {
  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5">
      <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-3 text-xl font-semibold text-white">{props.value}</p>
    </div>
  );
}

export default function ProfilePage() {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#071011_0%,#091416_100%)] px-6 py-10 text-stone-100 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl space-y-8">
        <DashboardTopBar />
        <DashboardCourseTabs />
        <section className="rounded-[2rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
          <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
            Profile
          </p>
          <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
            Personal details
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-8 text-stone-200">
            This screen is for the user profile view, where name and account
            identity can live in a cleaner dedicated space.
          </p>
          <div className="mt-8 grid gap-4 lg:grid-cols-3">
            <DetailCard label="Full name" value="Rahul Panchal" />
            <DetailCard label="Email" value="rahulsp4601@gmail.com" />
            <DetailCard label="Provider" value="Google" />
          </div>
        </section>
      </div>
    </main>
  );
}
