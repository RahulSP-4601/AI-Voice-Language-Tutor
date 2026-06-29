function lessonRanges() {
  return [
    [1, 100],
    [101, 200],
    [201, 300],
    [301, 400],
    [401, 500],
    [501, 600],
    [601, 700],
    [701, 770],
  ];
}

function demoEntry(entries, start) {
  return entries[start - 1] ?? entries[0];
}

function moduleRow(index, start, end) {
  const lessonNumber = index + 1;
  return {
    id: `jp-n5-lesson-${lessonNumber}`,
    language_slug: "japanese",
    level_id: "jp-n5",
    title: `Lesson ${lessonNumber}`,
    objective: `Practice N5 words ${start}-${end} one at a time with English meaning support and saved speaking progress.`,
    checkpoint_label: `Words ${start}-${end}`,
    support_language_hint: "Hear the Japanese, hear the English meaning, repeat clearly, then save the card when it feels natural.",
    completion_state: "not_started",
    reward_badge: `Lesson ${lessonNumber} complete`,
    reward_xp: lessonNumber === 8 ? 70 : 100,
    coverage: [`Words ${start}-${end}`, "Listening", "Speaking recall"],
    mission_title: `Lesson ${lessonNumber}`,
    story_hook: `Move through N5 words ${start}-${end} in a focused speaking deck that keeps the learner in motion.`,
    progress_defaults: { state: "not_started", completedLessons: 0, totalLessons: 1 },
    resource_links: { vocabularyRanges: [{ start, end }] },
    sort_order: index,
  };
}

function lessonRow(index, start, end, entries) {
  const lessonNumber = index + 1;
  const demo = demoEntry(entries, start);
  return {
    id: `jp-n5-lesson-${lessonNumber}-practice`,
    language_slug: "japanese",
    level_id: "jp-n5",
    module_id: `jp-n5-lesson-${lessonNumber}`,
    title: `Lesson ${lessonNumber} practice`,
    duration_minutes: 18,
    mode: "speaking",
    demo_phrase: demo.japanese,
    reply_prompt: `Say ${demo.japanese} clearly, then continue through words ${start}-${end}.`,
    target_pattern: `N5 words ${start}-${end}`,
    learner_outcome: `Learner can hear, understand, and speak the ${end - start + 1} words assigned to Lesson ${lessonNumber}.`,
    acceptable_responses: [demo.japanese, demo.reading],
    turns: [],
    feedback: {
      focus: "Clear speaking, exact match, and confident recall",
      successSignal: "Learner reaches 100/100 and marks each card green manually.",
      correctionStyle: "Short pronunciation correction plus one retry.",
      retryCue: "Listen again, slow down slightly, and match the reading exactly.",
    },
    sort_order: index,
  };
}

export function buildJlptN5CourseStructure(entries) {
  const modules = [];
  const lessons = [];

  lessonRanges().forEach(([start, end], index) => {
    modules.push(moduleRow(index, start, end));
    lessons.push(lessonRow(index, start, end, entries));
  });

  return { lessons, modules };
}
