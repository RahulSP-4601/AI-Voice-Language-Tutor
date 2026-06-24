import {
  DashboardHeader,
  DashboardNextStep,
  DashboardTrackGrid,
} from "@/components/dashboard-sections";

export default function DashboardPage() {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#071011_0%,#091416_100%)] px-6 py-10 text-stone-100 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl space-y-8">
        <DashboardHeader />
        <DashboardTrackGrid />
        <DashboardNextStep />
      </div>
    </main>
  );
}
