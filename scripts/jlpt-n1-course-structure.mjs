const LESSON_SIZE = 100;
const STORED_SORT_OFFSET = 4000;

function lessonRanges(totalEntries) {
  const lessonCount = Math.ceil(totalEntries / LESSON_SIZE);

  return Array.from({ length: lessonCount }, (_, index) => {
    const visibleStart = index * LESSON_SIZE + 1;
    const visibleEnd = Math.min((index + 1) * LESSON_SIZE, totalEntries);
    return {
      visibleStart,
      visibleEnd,
      storedStart: STORED_SORT_OFFSET + visibleStart,
      storedEnd: STORED_SORT_OFFSET + visibleEnd,
    };
  });
}

function demoEntry(entries, visibleStart) {
  return entries[visibleStart - 1] ?? entries[0];
}

function moduleRow(index, range) {
  const lessonNumber = index + 1;
  return {
    id: `jp-n1-lesson-${lessonNumber}`,
    language_slug: "japanese",
    level_id: "jp-n1",
    title: `Lesson ${lessonNumber}`,
    objective: `Practice N1 words ${range.visibleStart}-${range.visibleEnd} one at a time with English meaning support and saved speaking progress.`,
    checkpoint_label: `Words ${range.visibleStart}-${range.visibleEnd}`,
    support_language_hint: "Hear the Japanese, hear the English meaning, repeat clearly, then save the card when it feels natural.",
    completion_state: "not_started",
    reward_badge: `Lesson ${lessonNumber} complete`,
    reward_xp: 100,
    coverage: [`Words ${range.visibleStart}-${range.visibleEnd}`, "Listening", "Speaking recall"],
    mission_title: `Lesson ${lessonNumber}`,
    story_hook: `Move through N1 words ${range.visibleStart}-${range.visibleEnd} in a focused speaking deck that keeps the learner in motion.`,
    progress_defaults: { state: "not_started", completedLessons: 0, totalLessons: 1 },
    resource_links: { vocabularyRanges: [{ start: range.storedStart, end: range.storedEnd }] },
    sort_order: index,
  };
}

function lessonRow(index, range, entries) {
  const lessonNumber = index + 1;
  const demo = demoEntry(entries, range.visibleStart);
  return {
    id: `jp-n1-lesson-${lessonNumber}-practice`,
    language_slug: "japanese",
    level_id: "jp-n1",
    module_id: `jp-n1-lesson-${lessonNumber}`,
    title: `Lesson ${lessonNumber} practice`,
    duration_minutes: 20,
    mode: "speaking",
    demo_phrase: demo?.japanese ?? `Lesson ${lessonNumber}`,
    reply_prompt: `Say ${demo?.japanese ?? "the example card"} clearly, then continue through N1 words ${range.visibleStart}-${range.visibleEnd}.`,
    target_pattern: `N1 words ${range.visibleStart}-${range.visibleEnd}`,
    learner_outcome: `Learner can hear, understand, and speak the ${range.visibleEnd - range.visibleStart + 1} words assigned to Lesson ${lessonNumber}.`,
    acceptable_responses: demo ? [demo.japanese, demo.reading] : [],
    turns: [],
    feedback: {
      focus: "Clear speaking, exact match, and confident recall",
      successSignal: "Learner reaches the target cards for the lesson and marks them green manually.",
      correctionStyle: "Short pronunciation correction plus one retry.",
      retryCue: "Listen again, slow down slightly, and match the reading exactly.",
    },
    sort_order: lessonNumber - 1,
  };
}

export function buildJlptN1CourseStructure(entries) {
  const modules = [];
  const lessons = [];

  lessonRanges(entries.length).forEach((range, index) => {
    modules.push(moduleRow(index, range));
    lessons.push(lessonRow(index, range, entries));
  });

  return { lessons, modules };
}
