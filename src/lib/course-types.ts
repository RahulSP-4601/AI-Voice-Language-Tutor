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

export interface CourseLesson {
  id: string;
  title: string;
  durationMinutes: number;
  mode: LessonMode;
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
  slug: CourseSlug;
  name: string;
  bundlePrice: number;
  nativeSupportLabel: string;
  heroSummary: string;
  lessonDuration: string;
  framework: CourseFramework;
}

export interface VoiceLessonSeed {
  checkpoint: string;
  checkpointLabel: string;
  guidedPrompt: string;
  id: string;
  mode: LessonMode;
  modelPrompt: string;
  objective: string;
  outcome: string;
  pattern: string;
  state: CompletionState;
  supportHint: string;
  supportNote: string;
  title: string;
}
