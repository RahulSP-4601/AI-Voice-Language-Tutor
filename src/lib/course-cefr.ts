import { createLevel, createModule, createPlaceholderLevel } from "@/lib/course-builders";
import { type LanguageCourseDefinition, type VoiceLessonSeed } from "@/lib/course-types";

const cefrA1Templates = [
  ["sounds", "Sounds and alphabet patterns", "Build confidence with {language} sound patterns before longer spoken exchanges.", "Sound pattern check", "Use the learner's native language only for quick pronunciation coaching.", "Keep the support-language correction short and physical.", "completed", "repeat", "core beginner sounds", "Learner can repeat key {language} sounds with cleaner rhythm.", "Model the starter sound pattern and contrast the common beginner mistake.", "Ask the learner to repeat twice, then use the sound inside one short phrase.", "Confirm the learner can repeat the final phrase without breaking flow."],
  ["greetings", "Greetings", "Create a natural first interaction loop with hello, goodbye, thanks, and courtesy language.", "Greeting exchange", "Explain usage quickly, then move back into roleplay.", "Translate the social intention, not every single word.", "in_progress", "roleplay", "{phrase}", "Learner can handle a short {language} greeting exchange aloud.", "Model a warm first meeting in {language} with one greeting and one courtesy phrase.", "Roleplay a first meeting and ask the learner to respond naturally in one or two lines.", "Complete a clean greeting exchange without a written script."],
  ["numbers", "Numbers", "Build speaking access to numbers for time, age, prices, and everyday use.", "Number response check", "Use the support language only if a number pattern needs one quick explanation.", "Correct one sound or stress issue at a time.", "not_started", "speaking", "1-10 and simple details", "Learner can answer simple number prompts in {language}.", "Model one to ten naturally, then inside two small real-life questions.", "Ask for age, a simple quantity, and one time-related number.", "The learner answers three number prompts correctly in voice."],
  ["intros", "Introductions", "Help the learner say who they are, where they are from, and one personal detail.", "Self-introduction check", "Keep grammar explanation short and practical.", "Correct only what blocks understanding.", "not_started", "speaking", "name, origin, simple personal detail", "Learner can deliver a basic spoken introduction in {language}.", "Model a short self-introduction with clear pacing and natural confidence.", "Have the learner introduce themselves, then answer one follow-up question.", "Learner completes a two-line introduction without freezing."],
  ["objects", "Everyday objects", "Connect speech to familiar objects so the learner can answer simple environment prompts.", "Object naming check", "Use support language only to clarify meaning before another spoken attempt.", "Keep explanations light and conversational.", "not_started", "speaking", "high-frequency nouns", "Learner can say common objects and respond to simple prompts in {language}.", "Model common objects inside tiny phrases instead of isolated words.", "Ask what the learner has, sees, or wants using very short answers.", "The learner answers three object prompts clearly."],
  ["qa", "Simple question and answer patterns", "Build the first real conversation loop with predictable questions and short answers.", "Question-response check", "Use native-language support to explain the response pattern once if necessary.", "Favor momentum over over-explaining.", "not_started", "roleplay", "short personal answers", "Learner can answer a few beginner questions in {language}.", "Model a short prompt-response loop at a calm pace.", "Ask three predictable beginner questions and have the learner answer live.", "The learner completes a short three-question exchange."],
  ["listening", "Listening recognition", "Train quick listening so the learner starts reacting, not only repeating.", "Listening response check", "Give one listening tip, then test again right away.", "Keep corrections focused on one missed sound or one missed keyword.", "not_started", "listening", "short familiar phrases", "Learner can catch and answer a few familiar {language} phrases.", "Play a short phrase naturally and once again with slightly clearer articulation.", "Ask the learner what they heard and then request a spoken answer.", "The learner correctly recognizes the final phrase."],
  ["checkpoint", "Speak-and-repeat checkpoint", "Bring the A1 starter modules together into one guided speaking checkpoint.", "A1 foundation readiness", "Use support language only to calm the learner and keep them moving.", "Keep the tone motivating and premium, not exam-stiff.", "not_started", "checkpoint", "greetings, numbers, simple answers, and listening cues", "Learner can finish a compact A1 voice checkpoint in {language}.", "Model the checkpoint flow once from start to finish.", "Run a compact mixed speaking loop with greeting, intro, number, and listening prompts.", "Mark the module complete after the learner clears the final voice loop."],
] as const;

function renderText(template: string, languageName: string, phrase: string) {
  return template
    .replaceAll("{language}", languageName)
    .replaceAll("{phrase}", phrase);
}

function createCefrSeed(
  template: (typeof cefrA1Templates)[number],
  languageName: string,
  phrase: string,
): VoiceLessonSeed {
  const [
    suffix,
    title,
    objective,
    checkpointLabel,
    supportHint,
    supportNote,
    state,
    mode,
    pattern,
    outcome,
    modelPrompt,
    guidedPrompt,
    checkpoint,
  ] = template;

  return {
    id: `${languageName}-a1-${suffix}`,
    title,
    objective: renderText(objective, languageName, phrase),
    checkpointLabel,
    supportHint,
    supportNote,
    state,
    mode,
    pattern: renderText(pattern, languageName, phrase),
    outcome: renderText(outcome, languageName, phrase),
    modelPrompt: renderText(modelPrompt, languageName, phrase),
    guidedPrompt,
    checkpoint,
  };
}

function createCefrA1Seeds(languageName: string, phrase: string) {
  return cefrA1Templates.map((template) =>
    createCefrSeed(template, languageName, phrase),
  );
}

function createCefrLevels(languageName: string, phrase: string, titlePrefix: string) {
  return [
    createCefrLevel(languageName, phrase, titlePrefix),
    createPlaceholderLevel({
      id: `${titlePrefix}-a2`,
      officialLabel: "A2",
      productLabel: "Basic 2",
      objective: `Move from first ${languageName} phrases into broader daily communication.`,
    }),
    createPlaceholderLevel({
      id: `${titlePrefix}-b1`,
      officialLabel: "B1",
      productLabel: "Intermediate 1",
      objective: `Handle more independent ${languageName} conversations with confidence.`,
    }),
    createPlaceholderLevel({
      id: `${titlePrefix}-b2`,
      officialLabel: "B2",
      productLabel: "Intermediate 2",
      objective: `Grow ${languageName} flexibility, speed, and listening resilience.`,
    }),
    createPlaceholderLevel({
      id: `${titlePrefix}-c1`,
      officialLabel: "C1",
      productLabel: "Advanced 1",
      objective: `Develop advanced ${languageName} expression for study and work.`,
    }),
    createPlaceholderLevel({
      id: `${titlePrefix}-c2`,
      officialLabel: "C2",
      productLabel: "Advanced 2",
      objective: `Reach highly fluent and polished ${languageName} communication.`,
    }),
  ];
}

function createCefrLevel(
  languageName: string,
  phrase: string,
  titlePrefix: string,
) {
  return createLevel({
    id: `${titlePrefix}-a1`,
    officialLabel: "A1",
    productLabel: "Basic 1",
    objective: `Foundational ${languageName} speaking for greetings, introductions, and simple listening recognition.`,
    examTitle: "A1 speaking foundation exam",
    passRequirement: "Pass the guided A1 conversation and listening checkpoint.",
    certificateTitle: `${languageName} Basic 1 completion certificate`,
    certificateSummary: "Issued after the learner completes the A1 voice exam.",
    modules: createCefrA1Seeds(languageName, phrase).map(createModule),
  });
}

function createCefrCourse(input: {
  heroSummary: string;
  name: string;
  nativeSupportLabel: string;
  phrase: string;
  slug: LanguageCourseDefinition["slug"];
  titlePrefix: string;
}) {
  return {
    slug: input.slug,
    name: input.name,
    bundlePrice: 80,
    nativeSupportLabel: input.nativeSupportLabel,
    heroSummary: input.heroSummary,
    lessonDuration: "15-20 minute voice lesson",
    framework: {
      name: "CEFR",
      levels: createCefrLevels(input.name, input.phrase, input.titlePrefix),
    },
  } satisfies LanguageCourseDefinition;
}

export const englishCourse = createCefrCourse({
  slug: "english",
  titlePrefix: "en",
  name: "English",
  phrase: "hello, thank you, excuse me",
  nativeSupportLabel: "Native-language support active for confidence-first coaching",
  heroSummary: "A speaking-first English path built around live introductions, daily prompts, listening, and short guided roleplay.",
});

export const germanCourse = createCefrCourse({
  slug: "german",
  titlePrefix: "de",
  name: "German",
  phrase: "hallo, danke, entschuldigung",
  nativeSupportLabel: "Native-language support active for practical pronunciation correction",
  heroSummary: "A structured German voice path focused on crisp pronunciation, beginner survival phrases, and confidence through repetition.",
});

export const spanishCourse = createCefrCourse({
  slug: "spanish",
  titlePrefix: "es",
  name: "Spanish",
  phrase: "hola, gracias, perdon",
  nativeSupportLabel: "Native-language support active for short confidence-building corrections",
  heroSummary: "A warm Spanish speaking path designed around fast repetition, friendly roleplay, and real-world response practice.",
});

export const frenchCourse = createCefrCourse({
  slug: "french",
  titlePrefix: "fr",
  name: "French",
  phrase: "bonjour, merci, excusez-moi",
  nativeSupportLabel: "Native-language support active for compact pronunciation guidance",
  heroSummary: "A premium French speaking track with rhythm coaching, fast feedback, and short guided conversation loops.",
});
