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
      "The dashboard immediately points users into the free level so they feel value before any upsell pressure.",
  },
] as const;

export const processHighlights = [
  "Premium landing page establishes trust in under 10 seconds.",
  "Google login removes friction and keeps the first conversion clean.",
  "A focused dashboard gives users one obvious next action after auth.",
] as const;

export const landingComparison = [
  {
    title: "Speaking over memorization",
    description:
      "Instead of trapping users in passive vocabulary loops, the product makes them hear, repeat, and improve live.",
  },
  {
    title: "Certificate before bundle",
    description:
      "Users get a real completion moment before they ever see the $80 bundle decision, which builds trust.",
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
      "The free certificate gives users a reason to believe the learning path is real before they buy the bundle.",
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
  { value: "1", label: "Free level with certificate before upgrade." },
  { value: "$80", label: "Full bundle unlock for each language path." },
] as const;

export const dashboardTracks = [
  {
    name: "Japanese",
    status: "Active",
    summary:
      "This is the hero path for the current dashboard preview and the cleanest first-time user story.",
    stats: [
      { label: "Current level", value: "Basic 1" },
      { label: "Certificate path", value: "Open" },
      { label: "Bundle later", value: "$80" },
    ],
  },
  {
    name: "English",
    status: "Saved",
    summary:
      "Users can explore more than one language later, but the dashboard should still highlight a main active track.",
    stats: [
      { label: "Current level", value: "Not started" },
      { label: "Certificate path", value: "Available" },
      { label: "Bundle later", value: "$80" },
    ],
  },
  {
    name: "German",
    status: "Saved",
    summary:
      "Additional languages stay visible so the business model feels expandable without cluttering the first experience.",
    stats: [
      { label: "Current level", value: "Not started" },
      { label: "Certificate path", value: "Available" },
      { label: "Bundle later", value: "$80" },
    ],
  },
] as const;

export const dashboardPhaseItems = [
  "Premium marketing landing page",
  "Google signup and login entry",
  "Simple post-login dashboard shell",
  "Clear setup for later onboarding and course flow",
] as const;
