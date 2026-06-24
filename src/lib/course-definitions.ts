export type {
  CompletionState,
  CourseFramework,
  CourseFrameworkName,
  LessonEvaluation,
  CourseLesson,
  CourseLevel,
  CourseModule,
  CourseSlug,
  LanguageCourseDefinition,
  LessonFeedback,
  LessonMode,
  LessonTurn,
  ModuleProgress,
} from "@/lib/course-types";

import {
  englishCourse,
  frenchCourse,
  germanCourse,
  spanishCourse,
} from "@/lib/course-cefr";
import { japaneseCourse } from "@/lib/course-japanese";
import { type CourseSlug, type LanguageCourseDefinition } from "@/lib/course-types";

export const courseDefinitions: Record<CourseSlug, LanguageCourseDefinition> = {
  japanese: japaneseCourse,
  english: englishCourse,
  german: germanCourse,
  spanish: spanishCourse,
  french: frenchCourse,
};

export const courseSlugs = Object.keys(courseDefinitions) as CourseSlug[];

export function isCourseSlug(value: string): value is CourseSlug {
  return courseSlugs.includes(value as CourseSlug);
}
