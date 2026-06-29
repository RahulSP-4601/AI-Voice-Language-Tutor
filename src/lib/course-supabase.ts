import { type SupabaseClient } from "@supabase/supabase-js";
import {
  type CourseLevel,
  type CourseModule,
  type CourseSlug,
  type LessonFeedback,
  type LessonTurn,
  type LanguageCourseDefinition,
  type LanguageCourseResources,
  type ModuleProgress,
  type ResourceLinkSet,
} from "@/lib/course-types";

type Row = Record<string, unknown>;

function byOrder(a: Row, b: Row) {
  return Number(a.sort_order ?? 0) - Number(b.sort_order ?? 0);
}

function text(value: unknown) {
  return typeof value === "string" ? value : "";
}

function list<T>(value: unknown) {
  return Array.isArray(value) ? (value as T[]) : [];
}

function object<T>(value: unknown) {
  return (value ?? {}) as T;
}

async function selectRows(
  client: SupabaseClient,
  table: string,
  slug: CourseSlug,
) {
  const query = client
    .from(table)
    .select("*")
    .eq("language_slug", slug)
    .order("sort_order", { ascending: true });
  const { data, error } = await query;
  if (error) {
    throw error;
  }
  return data ?? [];
}

async function selectLanguageRows(
  client: SupabaseClient,
  slug: CourseSlug,
) {
  const { data, error } = await client
    .from("curriculum_languages")
    .select("*")
    .eq("slug", slug);

  if (error) {
    throw error;
  }

  return data ?? [];
}

async function loadCurriculumRows(client: SupabaseClient, slug: CourseSlug) {
  const [languageRows, levelRows, moduleRows, lessonRows] = await Promise.all([
    selectLanguageRows(client, slug),
    selectRows(client, "curriculum_levels", slug),
    selectRows(client, "curriculum_modules", slug),
    selectRows(client, "curriculum_lessons", slug),
  ]);
  return { languageRows, lessonRows, levelRows, moduleRows };
}

async function loadResourceRows(client: SupabaseClient, slug: CourseSlug) {
  const [vocabCategoryRows, vocabEntryRows, kanjiGroupRows, kanjiEntryRows] =
    await Promise.all([
      selectRows(client, "curriculum_vocab_categories", slug),
      selectRows(client, "curriculum_vocab_entries", slug),
      selectRows(client, "curriculum_kanji_groups", slug),
      selectRows(client, "curriculum_kanji_entries", slug),
    ]);
  const [examSectionRows, examQuestionRows] = await Promise.all([
    selectRows(client, "curriculum_exam_sections", slug),
    selectRows(client, "curriculum_exam_questions", slug),
  ]);
  return {
    examQuestionRows,
    examSectionRows,
    kanjiEntryRows,
    kanjiGroupRows,
    vocabCategoryRows,
    vocabEntryRows,
  };
}

function buildLessons(moduleId: string, lessonRows: Row[]) {
  return lessonRows
    .filter((row) => text(row.module_id) === moduleId)
    .sort(byOrder)
    .map((row) => ({
      acceptableResponses: list<string>(row.acceptable_responses),
      demoPhrase: text(row.demo_phrase),
      durationMinutes: Number(row.duration_minutes ?? 0),
      feedback: lessonFeedback(row.feedback),
      id: text(row.id),
      learnerOutcome: text(row.learner_outcome),
      mode: row.mode as CourseModule["lessons"][number]["mode"],
      replyPrompt: text(row.reply_prompt),
      targetPattern: text(row.target_pattern),
      title: text(row.title),
      turns: list<LessonTurn>(row.turns),
    }));
}

function lessonFeedback(value: unknown) {
  return object<LessonFeedback>(value);
}

function moduleProgress(value: unknown) {
  return object<ModuleProgress>(value);
}

function resourceLinks(value: unknown) {
  return object<ResourceLinkSet>(value);
}

function buildModules(levelId: string, moduleRows: Row[], lessonRows: Row[]) {
  return moduleRows
    .filter((row) => text(row.level_id) === levelId)
    .sort(byOrder)
    .map((row) => ({
      checkpointLabel: text(row.checkpoint_label),
      completionState: row.completion_state as CourseModule["completionState"],
      experience: {
        coverage: list<string>(row.coverage),
        missionTitle: text(row.mission_title),
        storyHook: text(row.story_hook),
      },
      id: text(row.id),
      lessons: buildLessons(text(row.id), lessonRows),
      objective: text(row.objective),
      progress: moduleProgress(row.progress_defaults),
      resourceLinks: resourceLinks(row.resource_links),
      reward: {
        badge: text(row.reward_badge),
        xp: Number(row.reward_xp ?? 0),
      },
      supportLanguageHint: text(row.support_language_hint),
      title: text(row.title),
    }));
}

function buildLevels(levelRows: Row[], moduleRows: Row[], lessonRows: Row[]) {
  return levelRows.sort(byOrder).map((row) => ({
    certificateConfig: {
      summary: text(row.certificate_summary),
      title: text(row.certificate_title),
    },
    examConfig: {
      passRequirement: text(row.pass_requirement),
      title: text(row.exam_title),
    },
    id: text(row.id),
    modules: buildModules(text(row.id), moduleRows, lessonRows),
    objective: text(row.objective),
    officialLabel: text(row.official_label),
    productLabel: text(row.product_label),
  })) satisfies CourseLevel[];
}

function buildExamQuestions(rows: Row[]) {
  return rows.sort(byOrder).map((row) => ({
    choices: list<string>(row.choices),
    correctAnswer: text(row.correct_answer),
    explanation: text(row.explanation),
    id: text(row.id),
    prompt: text(row.prompt),
    questionType: text(row.question_type),
    sectionId: text(row.section_id),
    skillFocus: text(row.skill_focus),
  }));
}

function buildExamSections(rows: Row[]) {
  return rows.sort(byOrder).map((row) => ({
    coverage: list<string>(row.coverage),
    id: text(row.id),
    passSignal: text(row.pass_signal),
    questionTypes: list<string>(row.question_types),
    title: text(row.title),
  }));
}

function buildKanjiGroups(groupRows: Row[], entryRows: Row[]) {
  return groupRows.sort(byOrder).map((row) => ({
    entries: entryRows
      .filter((entry) => text(entry.group_id) === text(row.id))
      .sort(byOrder)
      .map((entry) => ({
        id: text(entry.id),
        example: text(entry.example),
        japanese: text(entry.japanese),
        meaning: text(entry.meaning),
        reading: text(entry.reading),
        sortOrder: Number(entry.sort_order ?? 0),
      })),
    id: text(row.id),
    title: text(row.title),
  }));
}

function buildVocabularyCategories(categoryRows: Row[], entryRows: Row[]) {
  return categoryRows.sort(byOrder).map((row) => ({
    entries: entryRows
      .filter((entry) => text(entry.category_id) === text(row.id))
      .sort(byOrder)
      .map((entry) => ({
        id: text(entry.id),
        english: text(entry.english),
        example: text(entry.example),
        japanese: text(entry.japanese),
        romaji: text(entry.romaji),
        sortOrder: Number(entry.sort_order ?? 0),
      })),
    id: text(row.id),
    title: text(row.title),
  }));
}

function buildResources(rows: Awaited<ReturnType<typeof loadResourceRows>>) {
  return {
    examQuestions: buildExamQuestions(rows.examQuestionRows),
    examSections: buildExamSections(rows.examSectionRows),
    kanjiGroups: buildKanjiGroups(rows.kanjiGroupRows, rows.kanjiEntryRows),
    vocabularyCategories: buildVocabularyCategories(
      rows.vocabCategoryRows,
      rows.vocabEntryRows,
    ),
  } satisfies LanguageCourseResources;
}

function buildCourse(
  slug: CourseSlug,
  courseRow: Row,
  levels: CourseLevel[],
  resources: LanguageCourseResources,
) {
  return {
    framework: {
      levels,
      name: text(courseRow.framework_name) as LanguageCourseDefinition["framework"]["name"],
    },
    heroSummary: text(courseRow.hero_summary),
    lessonDuration: text(courseRow.lesson_duration),
    name: text(courseRow.name),
    nativeSupportLabel: text(courseRow.native_support_label),
    resources,
    slug,
  } satisfies LanguageCourseDefinition;
}

export async function loadCourseFromSupabaseClient(
  client: SupabaseClient,
  slug: CourseSlug,
) {
  const curriculumRows = await loadCurriculumRows(client, slug);
  const courseRow = curriculumRows.languageRows[0];
  if (!courseRow) {
    return null;
  }

  const resources = await loadResourceRows(client, slug);
  return buildCourse(
    slug,
    courseRow,
    buildLevels(
      curriculumRows.levelRows,
      curriculumRows.moduleRows,
      curriculumRows.lessonRows,
    ),
    buildResources(resources),
  );
}
