import { notFound } from "next/navigation";
import {
  CourseHero,
  DashboardCourseTabs,
  DashboardTopBar,
} from "@/components/dashboard-sections";
import {
  dashboardCourses,
  type DashboardCourseSlug,
} from "@/lib/product-content";

function isCourseSlug(value: string): value is DashboardCourseSlug {
  return dashboardCourses.some((course) => course.slug === value);
}

export default async function CoursePage({
  params,
}: {
  params: Promise<{ language: string }>;
}) {
  const { language } = await params;

  if (!isCourseSlug(language)) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#071011_0%,#091416_100%)] px-6 py-10 text-stone-100 sm:px-10 lg:px-14">
      <div className="mx-auto max-w-7xl space-y-8">
        <DashboardTopBar />
        <DashboardCourseTabs activeSlug={language} />
        <CourseHero activeSlug={language} />
      </div>
    </main>
  );
}
