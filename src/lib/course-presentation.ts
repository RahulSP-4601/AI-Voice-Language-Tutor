import {
  type CourseFrameworkName,
  type CourseLevel,
  type CourseSlug,
} from "@/lib/course-definitions";

const RELEASED_COURSE_SLUGS: CourseSlug[] = ["japanese"];

export function isCourseReleased(slug: CourseSlug) {
  return RELEASED_COURSE_SLUGS.includes(slug);
}

export function getCourseAvailabilityLabel(slug: CourseSlug) {
  return isCourseReleased(slug) ? "Open now" : "Coming soon";
}

export function getLevelProductLabel(
  frameworkName: CourseFrameworkName,
  level: CourseLevel,
) {
  return frameworkName === "JLPT" ? "JLPT level" : level.productLabel;
}
