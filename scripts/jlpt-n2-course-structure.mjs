const LESSON_SIZE = 100;
const STORED_SORT_OFFSET = 3000;

function buildVocabRanges(totalEntries) {
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

function demoEntry(entries, start) {
  return entries[start - 1] ?? entries[0];
}

function vocabModuleRow(index, range) {
  const lessonNumber = index + 1;
  return {
    id: `jp-n2-lesson-${lessonNumber}`,
    language_slug: "japanese",
    level_id: "jp-n2",
    title: `Lesson ${lessonNumber}`,
    objective: `Practice N2 vocabulary words ${range.visibleStart}-${range.visibleEnd} with English meaning support and saved speaking progress.`,
    checkpoint_label: `Vocabulary ${range.visibleStart}-${range.visibleEnd}`,
    support_language_hint: "Hear the Japanese, hear the English meaning, repeat clearly, then save the card when it feels natural.",
    completion_state: "not_started",
    reward_badge: `Lesson ${lessonNumber} complete`,
    reward_xp: 100,
    coverage: [`Words ${range.visibleStart}-${range.visibleEnd}`, "Listening", "Speaking recall"],
    mission_title: `Lesson ${lessonNumber}`,
    story_hook: `Move through N2 vocabulary words ${range.visibleStart}-${range.visibleEnd} in one focused speaking deck.`,
    progress_defaults: { state: "not_started", completedLessons: 0, totalLessons: 1 },
    resource_links: { vocabularyRanges: [{ start: range.storedStart, end: range.storedEnd }] },
    sort_order: index,
  };
}

function vocabLessonRow(index, range, entries) {
  const lessonNumber = index + 1;
  const demo = demoEntry(entries, range.visibleStart);
  return {
    id: `jp-n2-lesson-${lessonNumber}-practice`,
    language_slug: "japanese",
    level_id: "jp-n2",
    module_id: `jp-n2-lesson-${lessonNumber}`,
    title: `Lesson ${lessonNumber} practice`,
    duration_minutes: 20,
    mode: "speaking",
    demo_phrase: demo?.japanese ?? `Lesson ${lessonNumber}`,
    reply_prompt: `Say ${demo?.japanese ?? "the example card"} clearly, then continue through N2 vocabulary words ${range.visibleStart}-${range.visibleEnd}.`,
    target_pattern: `N2 vocabulary words ${range.visibleStart}-${range.visibleEnd}`,
    learner_outcome: `Learner can hear, understand, and speak the N2 vocabulary assigned to Lesson ${lessonNumber}.`,
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

function kanjiModuleRow(index, group, vocabLessonCount) {
  const lessonNumber = vocabLessonCount + index + 1;
  return {
    id: `jp-n2-lesson-${lessonNumber}`,
    language_slug: "japanese",
    level_id: "jp-n2",
    title: `Lesson ${lessonNumber}`,
    objective: `Practice ${group.title.toLowerCase()} with English meaning support and saved speaking progress.`,
    checkpoint_label: group.title,
    support_language_hint: "Hear the Japanese, hear the English meaning, repeat clearly, then save the card when it feels natural.",
    completion_state: "not_started",
    reward_badge: `Lesson ${lessonNumber} complete`,
    reward_xp: 100,
    coverage: [group.title, "Kanji recognition", "Speaking recall"],
    mission_title: `Lesson ${lessonNumber}`,
    story_hook: `Move through ${group.title.toLowerCase()} in one focused kanji speaking deck.`,
    progress_defaults: { state: "not_started", completedLessons: 0, totalLessons: 1 },
    resource_links: { kanjiGroupIds: [group.id] },
    sort_order: lessonNumber - 1,
  };
}

function kanjiLessonRow(index, group, vocabLessonCount) {
  const lessonNumber = vocabLessonCount + index + 1;
  const demo = group.entries[0];
  return {
    id: `jp-n2-lesson-${lessonNumber}-practice`,
    language_slug: "japanese",
    level_id: "jp-n2",
    module_id: `jp-n2-lesson-${lessonNumber}`,
    title: `Lesson ${lessonNumber} practice`,
    duration_minutes: 20,
    mode: "speaking",
    demo_phrase: demo?.japanese ?? `Lesson ${lessonNumber}`,
    reply_prompt: `Say ${demo?.japanese ?? "the example kanji"} clearly, then continue through ${group.title.toLowerCase()}.`,
    target_pattern: `${group.title} speaking practice`,
    learner_outcome: `Learner can hear, understand, and speak the kanji entries assigned to Lesson ${lessonNumber}.`,
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

export function buildJlptN2CourseStructure(vocabularyEntries, kanjiGroupsWithEntries) {
  const modules = [];
  const lessons = [];
  const vocabRanges = buildVocabRanges(vocabularyEntries.length);

  vocabRanges.forEach((range, index) => {
    modules.push(vocabModuleRow(index, range));
    lessons.push(vocabLessonRow(index, range, vocabularyEntries));
  });

  kanjiGroupsWithEntries.forEach((group, index) => {
    modules.push(kanjiModuleRow(index, group, vocabRanges.length));
    lessons.push(kanjiLessonRow(index, group, vocabRanges.length));
  });

  return { lessons, modules };
}
