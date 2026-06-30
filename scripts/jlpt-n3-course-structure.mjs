const VOCAB_LESSON_COUNT = 8;
const KANJI_LESSON_COUNT = 1;
const VOCAB_SORT_OFFSET = 2000;

function buildRanges(totalEntries, lessonCount) {
  const baseSize = Math.floor(totalEntries / lessonCount);
  const remainder = totalEntries % lessonCount;
  const ranges = [];
  let cursor = 1;

  for (let index = 0; index < lessonCount; index += 1) {
    const size = baseSize + (index < remainder ? 1 : 0);
    const start = cursor;
    const end = size > 0 ? cursor + size - 1 : cursor - 1;
    ranges.push({ end, start });
    cursor = end + 1;
  }

  return ranges;
}

function storedRange(range) {
  return {
    end: VOCAB_SORT_OFFSET + range.end,
    start: VOCAB_SORT_OFFSET + range.start,
  };
}

function vocabModuleRow(index, range) {
  const lessonNumber = index + 1;
  return {
    id: `jp-n3-lesson-${lessonNumber}`,
    language_slug: "japanese",
    level_id: "jp-n3",
    title: `Lesson ${lessonNumber}`,
    objective: `Practice N3 vocabulary words ${range.start}-${range.end} with English meaning support and saved speaking progress.`,
    checkpoint_label: `Vocabulary ${range.start}-${range.end}`,
    support_language_hint: "Hear the Japanese, hear the English meaning, repeat clearly, then save the card when it feels natural.",
    completion_state: "not_started",
    reward_badge: `Lesson ${lessonNumber} complete`,
    reward_xp: 100,
    coverage: [`Words ${range.start}-${range.end}`, "Listening", "Speaking recall"],
    mission_title: `Lesson ${lessonNumber}`,
    story_hook: `Move through N3 vocabulary words ${range.start}-${range.end} in one focused speaking deck.`,
    progress_defaults: { state: "not_started", completedLessons: 0, totalLessons: 1 },
    resource_links: {
      vocabularyRanges: [storedRange(range)],
    },
    sort_order: index,
  };
}

function kanjiModuleRow(group) {
  const lessonNumber = VOCAB_LESSON_COUNT + 1;
  return {
    id: `jp-n3-lesson-${lessonNumber}`,
    language_slug: "japanese",
    level_id: "jp-n3",
    title: `Lesson ${lessonNumber}`,
    objective: "Practice the N3 kanji bank with English meaning support and saved speaking progress.",
    checkpoint_label: "Kanji review bank",
    support_language_hint: "Hear the Japanese, hear the English meaning, repeat clearly, then save the card when it feels natural.",
    completion_state: "not_started",
    reward_badge: `Lesson ${lessonNumber} complete`,
    reward_xp: 100,
    coverage: [group.title, "Kanji recognition", "Speaking recall"],
    mission_title: `Lesson ${lessonNumber}`,
    story_hook: `Move through ${group.title.toLowerCase()} in one focused kanji speaking deck.`,
    progress_defaults: { state: "not_started", completedLessons: 0, totalLessons: 1 },
    resource_links: {
      kanjiGroupIds: [group.id],
    },
    sort_order: lessonNumber - 1,
  };
}

function vocabLessonRow(index, range, words) {
  const lessonNumber = index + 1;
  const demo = words[range.start - 1] ?? words[0];
  return {
    id: `jp-n3-lesson-${lessonNumber}-practice`,
    language_slug: "japanese",
    level_id: "jp-n3",
    module_id: `jp-n3-lesson-${lessonNumber}`,
    title: `Lesson ${lessonNumber} practice`,
    duration_minutes: 20,
    mode: "speaking",
    demo_phrase: demo?.japanese ?? `Lesson ${lessonNumber}`,
    reply_prompt: `Say ${demo?.japanese ?? "the example card"} clearly, then continue through N3 vocabulary words ${range.start}-${range.end}.`,
    target_pattern: `N3 vocabulary words ${range.start}-${range.end}`,
    learner_outcome: `Learner can hear, understand, and speak the N3 vocabulary assigned to Lesson ${lessonNumber}.`,
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

function kanjiLessonRow(group, entries) {
  const lessonNumber = VOCAB_LESSON_COUNT + 1;
  const demo = entries[0];
  return {
    id: `jp-n3-lesson-${lessonNumber}-practice`,
    language_slug: "japanese",
    level_id: "jp-n3",
    module_id: `jp-n3-lesson-${lessonNumber}`,
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

export function buildJlptN3CourseStructure(words, kanjiGroupWithEntries) {
  const modules = [];
  const lessons = [];
  const vocabRanges = buildRanges(words.length, VOCAB_LESSON_COUNT);

  vocabRanges.forEach((range, index) => {
    modules.push(vocabModuleRow(index, range));
    lessons.push(vocabLessonRow(index, range, words));
  });

  modules.push(kanjiModuleRow(kanjiGroupWithEntries));
  lessons.push(kanjiLessonRow(kanjiGroupWithEntries, kanjiGroupWithEntries.entries));

  return { lessons, modules };
}
