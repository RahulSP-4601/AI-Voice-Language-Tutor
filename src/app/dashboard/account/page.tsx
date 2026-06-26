import {
  DashboardCourseTabs,
  DashboardTopBar,
} from "@/components/dashboard-sections";
import { AccountSummaryPanel } from "@/components/account-summary-panel";

export default function AccountPage() {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#071011_0%,#091416_100%)] px-6 py-10 text-stone-100 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl space-y-8">
        <DashboardTopBar />
        <DashboardCourseTabs />
        <AccountSummaryPanel />
      </div>
    </main>
  );
}
