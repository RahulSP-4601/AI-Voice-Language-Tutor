import { type CourseSlug } from "@/lib/course-types";
import { staticCourseDefinitions } from "@/lib/course-source";
import { loadCourseFromSupabaseClient } from "@/lib/course-supabase";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";
import { getSupabaseServerClient } from "@/lib/supabase/server";

function staticCourse(slug: CourseSlug) {
  return staticCourseDefinitions[slug] ?? null;
}

export async function loadCourseDefinition(slug: CourseSlug) {
  if (slug !== "japanese") {
    return staticCourse(slug);
  }

  if (!hasSupabaseEnv()) {
    return null;
  }

  try {
    return await loadCourseFromSupabaseClient(
      getSupabaseServerClient(),
      slug,
    );
  } catch {
    return null;
  }
}

export async function loadCourseDefinitionInBrowser(slug: CourseSlug) {
  if (slug !== "japanese") {
    return staticCourse(slug);
  }

  if (!hasSupabaseEnv()) {
    return null;
  }

  try {
    return await loadCourseFromSupabaseClient(
      getSupabaseBrowserClient(),
      slug,
    );
  } catch {
    return null;
  }
}
