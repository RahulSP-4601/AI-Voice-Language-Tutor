import {
  englishCourse,
  frenchCourse,
  germanCourse,
  spanishCourse,
} from "@/lib/course-cefr";
import {
  type CourseSlug,
  type LanguageCourseDefinition,
} from "@/lib/course-types";

export const staticCourseDefinitions: Partial<
  Record<CourseSlug, LanguageCourseDefinition>
> = {
  english: englishCourse,
  german: germanCourse,
  spanish: spanishCourse,
  french: frenchCourse,
};

export const courseSlugs: CourseSlug[] = [
  "japanese",
  "english",
  "german",
  "spanish",
  "french",
];

export function isCourseSlug(value: string): value is CourseSlug {
  return courseSlugs.includes(value as CourseSlug);
}
