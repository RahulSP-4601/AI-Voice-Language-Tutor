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

export interface ModuleExperience {
  coverage: string[];
  missionTitle: string;
  storyHook: string;
}

export interface ModuleReward {
  badge: string;
  xp: number;
}

export interface VocabularyEntry {
  english: string;
  example: string;
  japanese: string;
  romaji: string;
}

export interface VocabularyCategory {
  entries: VocabularyEntry[];
  id: string;
  title: string;
}

export interface KanjiEntry {
  example: string;
  japanese: string;
  meaning: string;
  reading: string;
}

export interface KanjiGroup {
  entries: KanjiEntry[];
  id: string;
  title: string;
}

export interface ExamSection {
  coverage: string[];
  id: string;
  passSignal: string;
  questionTypes: string[];
  title: string;
}

export interface ExamQuestion {
  choices: string[];
  correctAnswer: string;
  explanation: string;
  id: string;
  prompt: string;
  questionType: string;
  sectionId: string;
  skillFocus: string;
}

export interface ResourceLinkSet {
  examSectionIds?: string[];
  kanjiGroupIds?: string[];
  vocabularyCategoryIds?: string[];
}

export interface LanguageCourseResources {
  examQuestions: ExamQuestion[];
  examSections: ExamSection[];
  kanjiGroups: KanjiGroup[];
  vocabularyCategories: VocabularyCategory[];
}

export interface CourseModule {
  experience: ModuleExperience;
  id: string;
  title: string;
  objective: string;
  checkpointLabel: string;
  supportLanguageHint: string;
  completionState: CompletionState;
  progress: ModuleProgress;
  resourceLinks?: ResourceLinkSet;
  reward: ModuleReward;
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
  resources?: LanguageCourseResources;
  slug: CourseSlug;
}

export interface VoiceLessonSeed {
  acceptableResponses: string[];
  checkpoint: string;
  checkpointLabel: string;
  coverage?: string[];
  demoPhrase: string;
  guidedPrompt: string;
  id: string;
  mode: LessonMode;
  missionTitle?: string;
  modelPrompt: string;
  objective: string;
  outcome: string;
  pattern: string;
  replyPrompt: string;
  resourceLinks?: ResourceLinkSet;
  rewardBadge?: string;
  rewardXp?: number;
  state: CompletionState;
  storyHook?: string;
  supportHint: string;
  supportNote: string;
  title: string;
}
