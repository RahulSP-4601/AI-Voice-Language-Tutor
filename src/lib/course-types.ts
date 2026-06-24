export type CourseSlug =
  | "japanese"
  | "english"
  | "german"
  | "spanish"
  | "french";

export type CourseFrameworkName = "JLPT" | "CEFR";
export type CompletionState = "not_started" | "in_progress" | "completed";
export type LessonMode =
  | "speaking"
  | "listening"
  | "repeat"
  | "roleplay"
  | "checkpoint";

export interface LessonTurn {
  id: string;
  label: string;
  type:
    | "warm_up"
    | "ai_model"
    | "learner_repeat"
    | "feedback"
    | "retry"
    | "guided_prompt"
    | "checkpoint"
    | "summary";
  prompt: string;
  supportNote: string;
}

export interface LessonFeedback {
  focus: string;
  successSignal: string;
  correctionStyle: string;
  retryCue: string;
}

export interface LessonEvaluation {
  accuracyScore: number;
  coachingFeedback: string;
  deepgramConfidence: number;
  fluencyScore: number;
  matchedExpectedPhrase: boolean;
  pronunciationScore: number;
  shouldAdvance: boolean;
  transcript: string;
}

export interface CourseLesson {
  acceptableResponses: string[];
  demoPhrase: string;
  id: string;
  title: string;
  durationMinutes: number;
  mode: LessonMode;
  replyPrompt: string;
  targetPattern: string;
  learnerOutcome: string;
  turns: LessonTurn[];
  feedback: LessonFeedback;
}

export interface ModuleProgress {
  state: CompletionState;
  completedLessons: number;
  totalLessons: number;
}

export interface CourseModule {
  id: string;
  title: string;
  objective: string;
  checkpointLabel: string;
  supportLanguageHint: string;
  completionState: CompletionState;
  progress: ModuleProgress;
  lessons: CourseLesson[];
}

export interface CourseLevel {
  id: string;
  officialLabel: string;
  productLabel: string;
  objective: string;
  examConfig: {
    title: string;
    passRequirement: string;
  };
  certificateConfig: {
    title: string;
    summary: string;
  };
  modules: CourseModule[];
}

export interface CourseFramework {
  name: CourseFrameworkName;
  levels: CourseLevel[];
}

export interface LanguageCourseDefinition {
  heroSummary: string;
  lessonDuration: string;
  framework: CourseFramework;
  name: string;
  nativeSupportLabel: string;
  slug: CourseSlug;
}

export interface VoiceLessonSeed {
  acceptableResponses: string[];
  checkpoint: string;
  checkpointLabel: string;
  demoPhrase: string;
  guidedPrompt: string;
  id: string;
  mode: LessonMode;
  modelPrompt: string;
  objective: string;
  outcome: string;
  pattern: string;
  replyPrompt: string;
  state: CompletionState;
  supportHint: string;
  supportNote: string;
  title: string;
}
