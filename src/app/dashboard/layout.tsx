import { AuthHashCleaner } from "@/components/auth-hash-cleaner";
import { DashboardAuthGuard } from "@/components/dashboard-auth-guard";

export default function DashboardLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <>
      <AuthHashCleaner />
      <DashboardAuthGuard>{children}</DashboardAuthGuard>
    </>
  );
}
