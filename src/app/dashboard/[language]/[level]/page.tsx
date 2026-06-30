import { notFound } from "next/navigation";
import {
  CourseWorkspace,
  DashboardTopBar,
} from "@/components/dashboard-sections";
import { isCourseSlug } from "@/lib/course-definitions";

export default async function CourseLevelPage({
  params,
}: {
  params: Promise<{ language: string; level: string }>;
}) {
  const { language, level } = await params;

  if (!isCourseSlug(language)) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#071011_0%,#091416_100%)] px-6 py-10 text-stone-100 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl space-y-8">
        <DashboardTopBar />
        <CourseWorkspace activeSlug={language} preferredLevel={level} />
      </div>
    </main>
  );
}
