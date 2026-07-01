export const landingLanguages = [
  {
    slug: "japanese",
    name: "Japanese",
    promise:
      "The live course available today. Start with pronunciation, guided replies, and the first JLPT N5 speaking steps.",
    framework: "JLPT N5",
    levels: "5 levels",
  },
  {
    slug: "german",
    name: "German",
    promise:
      "Planned next as a structured CEFR speaking path with guided practice and practical survival phrases.",
    framework: "CEFR A1-C2",
    levels: "6 levels",
  },
  {
    slug: "spanish",
    name: "Spanish",
    promise:
      "Designed for daily conversation drills, high-frequency phrases, and confidence-building speaking sessions.",
    framework: "CEFR A1-C2",
    levels: "6 levels",
  },
  {
    slug: "english",
    name: "English",
    promise:
      "Built for interview practice, clear everyday communication, and structured spoken progress.",
    framework: "CEFR A1-C2",
    levels: "6 levels",
  },
  {
    slug: "french",
    name: "French",
    promise:
      "Planned as a voice-first course for listening, rhythm, and clean beginner speaking progress.",
    framework: "CEFR A1-C2",
    levels: "6 levels",
  },
] as const;

export const landingSteps = [
  {
    title: "Create an account",
    description:
      "Sign up or log in first so the learner can enter the platform and access their dashboard.",
  },
  {
    title: "Choose a language",
    description:
      "After entering the dashboard, the learner selects the language they want to study.",
  },
  {
    title: "Choose the difficulty",
    description:
      "Inside the language path, the learner picks the level or difficulty that matches where they want to begin.",
  },
  {
    title: "Start learning",
    description:
      "Open the lesson and begin practicing through the guided learning flow.",
  },
] as const;

export const processHighlights = [
  "Create an account to enter the learning dashboard.",
  "Choose the language you want to learn.",
  "Pick the difficulty level that fits your starting point.",
  "Start the lesson and begin learning right away.",
] as const;

export const landingHeroStats = [
  { value: "1", label: "Japanese course is live right now." },
  { value: "Voice", label: "Tutor playback, recording, transcript, and scoring." },
  { value: "Free", label: "Current released lessons stay open to learners." },
] as const;

export const dashboardCourses = [
  {
    slug: "japanese",
    name: "Japanese",
    description:
      "Start the full JLPT N5 journey from absolute zero through romaji, kana, grammar, roleplay, and guided speaking practice.",
    currentLevel: "Basic 1",
    statusNote: "Absolute-zero missions are ready to start.",
    bundleStatus: "Open Access",
    bundleNote: "All current lessons are available to every learner.",
    nextLesson: "What is Japanese?",
    officialFramework: "JLPT",
    levels: [
      { name: "N5", summary: "Starter basics", completed: false },
      { name: "N4", summary: "Elementary foundation", completed: false },
      { name: "N3", summary: "Practical intermediate", completed: false },
      { name: "N2", summary: "Professional fluency", completed: false },
      { name: "N1", summary: "Advanced mastery", completed: false },
    ],
  },
  {
    slug: "english",
    name: "English",
    description:
      "Use the English path for interview confidence, daily communication practice, and structured speaking growth.",
    currentLevel: "Basic 1",
    statusNote: "Ready when you want to start.",
    bundleStatus: "Open Access",
    bundleNote: "Learners can begin the English course immediately.",
    nextLesson: "Introductions and basics",
    officialFramework: "CEFR",
    levels: [
      { name: "A1", summary: "Foundation", completed: false },
      { name: "A2", summary: "Elementary", completed: false },
      { name: "B1", summary: "Intermediate", completed: false },
      { name: "B2", summary: "Upper intermediate", completed: false },
      { name: "C1", summary: "Advanced", completed: false },
      { name: "C2", summary: "Mastery", completed: false },
    ],
  },
  {
    slug: "german",
    name: "German",
    description:
      "German stays available as a dedicated course button so the user can jump directly into that language path.",
    currentLevel: "Basic 1",
    statusNote: "Waiting for first lesson.",
    bundleStatus: "Open Access",
    bundleNote: "Learners can begin the German course immediately.",
    nextLesson: "Numbers and greetings",
    officialFramework: "CEFR",
    levels: [
      { name: "A1", summary: "Foundation", completed: false },
      { name: "A2", summary: "Elementary", completed: false },
      { name: "B1", summary: "Intermediate", completed: false },
      { name: "B2", summary: "Upper intermediate", completed: false },
      { name: "C1", summary: "Advanced", completed: false },
      { name: "C2", summary: "Mastery", completed: false },
    ],
  },
  {
    slug: "spanish",
    name: "Spanish",
    description:
      "Spanish opens as its own course path for warm daily speaking practice and structured progression.",
    currentLevel: "Basic 1",
    statusNote: "Free foundation course available.",
    bundleStatus: "Open Access",
    bundleNote: "Learners can begin the Spanish course immediately.",
    nextLesson: "Common phrases",
    officialFramework: "CEFR",
    levels: [
      { name: "A1", summary: "Foundation", completed: false },
      { name: "A2", summary: "Elementary", completed: false },
      { name: "B1", summary: "Intermediate", completed: false },
      { name: "B2", summary: "Upper intermediate", completed: false },
      { name: "C1", summary: "Advanced", completed: false },
      { name: "C2", summary: "Mastery", completed: false },
    ],
  },
  {
    slug: "french",
    name: "French",
    description:
      "French remains visible as its own button so the dashboard always feels like a complete multi-language product.",
    currentLevel: "Basic 1",
    statusNote: "Free course path is ready.",
    bundleStatus: "Open Access",
    bundleNote: "Learners can begin the French course immediately.",
    nextLesson: "Sounds and greetings",
    officialFramework: "CEFR",
    levels: [
      { name: "A1", summary: "Foundation", completed: false },
      { name: "A2", summary: "Elementary", completed: false },
      { name: "B1", summary: "Intermediate", completed: false },
      { name: "B2", summary: "Upper intermediate", completed: false },
      { name: "C1", summary: "Advanced", completed: false },
      { name: "C2", summary: "Mastery", completed: false },
    ],
  },
] as const;

export type DashboardCourseSlug = (typeof dashboardCourses)[number]["slug"];
