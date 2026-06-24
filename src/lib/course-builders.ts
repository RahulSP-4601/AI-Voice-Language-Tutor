import {
  type CourseLesson,
  type CourseLevel,
  type CourseModule,
  type LessonTurn,
  type VoiceLessonSeed,
} from "@/lib/course-types";

function createLessonTurns(seed: VoiceLessonSeed): LessonTurn[] {
  return [
    ["warm-up", "Warm-up", "warm_up", "Start with a short confidence reset and remind the learner what they are about to say.", seed.supportNote],
    ["model", "AI models the phrase", "ai_model", seed.modelPrompt, "The AI says it naturally first, then once more slowly."],
    ["repeat", "Learner repeats", "learner_repeat", "Learner answers by voice. The goal is speaking frequently, not reading long explanations.", "Capture pronunciation, timing, and confidence on the first attempt."],
    ["feedback", "Instant feedback", "feedback", "Give one short correction in the learner's support language, then return to speaking.", seed.supportNote],
    ["retry", "Retry", "retry", "Ask for one cleaner retry only when needed so the lesson keeps momentum.", "Prioritize clarity and confidence over perfection."],
    ["guided", "Guided prompt-response", "guided_prompt", seed.guidedPrompt, "Move from mimicry into real communication quickly."],
    ["checkpoint", "Module checkpoint", "checkpoint", seed.checkpoint, "Use a short spoken check before advancing progress."],
    ["summary", "Lesson summary", "summary", "End with a short spoken recap, what improved, and what to remember next.", "Keep the closeout concise so the lesson still feels live."],
  ].map(([suffix, label, type, prompt, supportNote]) => ({
    id: `${seed.id}-${suffix}`,
    label,
    type: type as LessonTurn["type"],
    prompt,
    supportNote,
  }));
}

function createFeedback() {
  return {
    focus: "Pronunciation, clarity, and response confidence",
    successSignal: "Learner can answer once naturally without relying on a written script.",
    correctionStyle: "One practical correction at a time in plain support-language wording.",
    retryCue: "Repeat once more with calmer pacing and a cleaner final syllable.",
  };
}

export function createTutorLoopLesson(seed: VoiceLessonSeed): CourseLesson {
  return {
    acceptableResponses: seed.acceptableResponses,
    demoPhrase: seed.demoPhrase,
    id: seed.id,
    title: seed.title,
    durationMinutes: 18,
    mode: seed.mode,
    replyPrompt: seed.replyPrompt,
    targetPattern: seed.pattern,
    learnerOutcome: seed.outcome,
    turns: createLessonTurns(seed),
    feedback: createFeedback(),
  };
}

export function createModule(seed: VoiceLessonSeed): CourseModule {
  const lessons = [createTutorLoopLesson(seed)];

  return {
    id: seed.id,
    title: seed.title,
    objective: seed.objective,
    checkpointLabel: seed.checkpointLabel,
    supportLanguageHint: seed.supportHint,
    completionState: seed.state,
    progress: {
      state: seed.state,
      completedLessons: seed.state === "completed" ? 1 : 0,
      totalLessons: 1,
    },
    lessons,
  };
}

export function createLevel(input: {
  certificateSummary: string;
  certificateTitle: string;
  examTitle: string;
  id: string;
  modules: CourseModule[];
  objective: string;
  officialLabel: string;
  passRequirement: string;
  productLabel: string;
}): CourseLevel {
  return {
    id: input.id,
    officialLabel: input.officialLabel,
    productLabel: input.productLabel,
    objective: input.objective,
    examConfig: {
      title: input.examTitle,
      passRequirement: input.passRequirement,
    },
    certificateConfig: {
      title: input.certificateTitle,
      summary: input.certificateSummary,
    },
    modules: input.modules,
  };
}

export function createPlaceholderLevel(input: {
  id: string;
  objective: string;
  officialLabel: string;
  productLabel: string;
}): CourseLevel {
  return createLevel({
    id: input.id,
    officialLabel: input.officialLabel,
    productLabel: input.productLabel,
    objective: input.objective,
    examTitle: `${input.officialLabel} speaking gate`,
    passRequirement: "Pass the level speaking checkpoint and final guided conversation.",
    certificateTitle: `${input.officialLabel} completion certificate`,
    certificateSummary: "Issued after the learner passes the level exam and completes all modules.",
    modules: [
      createModule({
        id: `${input.id}-roadmap`,
        title: "Progressive speaking roadmap",
        objective: "Unlock the next speaking curriculum with live listening, roleplay, and structured response practice.",
        checkpointLabel: "Roadmap preview",
        supportHint: "Support language stays available for short beginner explanations.",
        supportNote: "Keep the explanation simple, brief, and confidence-building.",
        state: "not_started",
        mode: "speaking",
        demoPhrase: "Ready to speak this level with the tutor?",
        pattern: "Live guided conversation preview",
        outcome: "Learner understands what speaking goals unlock in this level.",
        replyPrompt: "Say one short readiness response aloud.",
        acceptableResponses: ["yes", "ready", "i am ready"],
        modelPrompt: `The AI previews what ${input.officialLabel} speaking feels like in short phrases and live responses.`,
        guidedPrompt: "Ask the learner one simple readiness question and one short spoken reply.",
        checkpoint: "Confirm the learner is ready for the next speaking path.",
      }),
    ],
  });
}
