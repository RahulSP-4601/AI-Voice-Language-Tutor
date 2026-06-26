"use client";

import { useEffect, useState } from "react";
import {
  type CourseSlug,
  type LanguageCourseDefinition,
} from "@/lib/course-definitions";
import { loadCourseDefinitionInBrowser } from "@/lib/course-loader";

type CourseDefinitionState = {
  course: LanguageCourseDefinition | null;
  slug: CourseSlug | null;
};

export function useCourseDefinition(slug: CourseSlug) {
  const [state, setState] = useState<CourseDefinitionState>({
    course: null,
    slug: null,
  });

  useEffect(() => {
    let active = true;

    async function bootCourse() {
      const nextCourse = await loadCourseDefinitionInBrowser(slug);
      if (active) {
        setState({ course: nextCourse, slug });
      }
    }

    bootCourse();
    return () => {
      active = false;
    };
  }, [slug]);

  return {
    course: state.slug === slug ? state.course : null,
    loading: state.slug !== slug,
  };
}
