export const landingLanguages = [
  {
    name: "Japanese",
    script: "Kana + Voice",
    promise: "From zero to confident introductions, pronunciation, and a free first certificate.",
  },
  {
    name: "German",
    script: "A1 Foundation",
    promise: "Daily speaking drills designed for structure, clarity, and practical survival phrases.",
  },
  {
    name: "Spanish",
    script: "Everyday Flow",
    promise: "Warm, high-frequency conversation practice with faster speaking confidence gains.",
  },
  {
    name: "English",
    script: "Global Fluency",
    promise: "Professional speaking progress for interviews, travel, and daily confidence building.",
  },
  {
    name: "French",
    script: "Accent Focus",
    promise: "Elegant voice-first practice for rhythm, listening, and clean first-level progress.",
  },
] as const;

export const landingSteps = [
  {
    title: "Hook the user with a premium promise",
    description:
      "The landing page leads with a bold AI-speaking proposition, a free certificate story, and a clear first action.",
  },
  {
    title: "Use Google as the clean entry point",
    description:
      "Signup and login stay simple so users move quickly into the product without friction or second-guessing.",
  },
  {
    title: "Guide them to Basic 1",
    description:
      "The dashboard immediately points users into the first live lesson so they can start speaking without friction.",
  },
] as const;

export const processHighlights = [
  "Premium landing page establishes trust in under 10 seconds.",
  "Google login removes friction and keeps the first conversion clean.",
  "A focused dashboard gives users one obvious next action after auth: start learning.",
] as const;

export const landingComparison = [
  {
    title: "Speaking over memorization",
    description:
      "Instead of trapping users in passive vocabulary loops, the product makes them hear, repeat, and improve live.",
  },
  {
    title: "Real lessons before complexity",
    description:
      "Users start speaking inside structured lessons immediately instead of getting trapped in setup, pricing, or clutter.",
  },
  {
    title: "Premium funnel, not utility UI",
    description:
      "The experience should feel like a serious modern education brand, not a cheap tool with forms and tables.",
  },
] as const;

export const landingTestimonials = [
  {
    name: "Speaking-first brand",
    role: "Positioning direction",
    quote:
      "This feels like a premium coaching product, not another language app trying to win with flashcards.",
  },
  {
    name: "Trust-building entry",
    role: "Conversion direction",
    quote:
      "The first live lesson should prove the learning path is real within minutes, not after a long setup flow.",
  },
  {
    name: "Clean phase-one scope",
    role: "Execution direction",
    quote:
      "Landing page, Google auth, and a simple dashboard are enough to make the business feel tangible right away.",
  },
] as const;

export const landingHeroStats = [
  { value: "5", label: "Launch languages in the first release." },
  { value: "1", label: "One focused lesson flow to start speaking fast." },
  { value: "Free", label: "Every available course stays open to learners." },
] as const;

export const dashboardCourses = [
  {
    slug: "japanese",
    name: "Japanese",
    description:
      "Open the Japanese path to continue with Basic 1 speaking drills, pronunciation work, and certificate progress.",
    currentLevel: "Basic 1",
    statusNote: "Foundation lessons are ready to start.",
    bundleStatus: "Open Access",
    bundleNote: "All current lessons are available to every learner.",
    certificateState: "Open",
    nextLesson: "Greetings and sounds",
    officialFramework: "JLPT",
    levels: [
      { name: "N1", summary: "Advanced mastery", completed: false },
      { name: "N2", summary: "Professional fluency", completed: false },
      { name: "N3", summary: "Practical intermediate", completed: false },
      { name: "N4", summary: "Elementary foundation", completed: false },
      { name: "N5", summary: "Starter basics", completed: false },
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
    certificateState: "Available",
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
    certificateState: "Available",
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
      "Spanish opens as its own course path for warm daily speaking practice and certificate-driven progression.",
    currentLevel: "Basic 1",
    statusNote: "Free foundation course available.",
    bundleStatus: "Open Access",
    bundleNote: "Learners can begin the Spanish course immediately.",
    certificateState: "Available",
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
    certificateState: "Available",
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
