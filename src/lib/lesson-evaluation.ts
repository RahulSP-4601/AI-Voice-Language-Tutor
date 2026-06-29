import { type CourseLesson, type CourseSlug, type LessonEvaluation } from "@/lib/course-definitions";
import {
  buildSpeechScoreBand,
  getSpeechSupport,
} from "@/lib/language-speech";

type DeepgramResult = {
  confidence: number;
  transcript: string;
};

type OpenAiScorecard = Omit<LessonEvaluation, "deepgramConfidence" | "transcript">;
export async function transcribeWithDeepgram(input: {
  audioBuffer: ArrayBuffer;
  contentType: string;
  deepgramKey: string;
  deepgramModel: string;
  slug: CourseSlug;
}) {
  const support = getSpeechSupport(input.slug);
  const response = await fetch(
    `https://api.deepgram.com/v1/listen?model=${encodeURIComponent(
      input.deepgramModel,
    )}&smart_format=true&language=${encodeURIComponent(support.deepgramLanguage)}`,
    {
      body: input.audioBuffer,
      headers: {
        Authorization: `Token ${input.deepgramKey}`,
        "Content-Type": input.contentType,
      },
      method: "POST",
    },
  );

  if (!response.ok) {
    throw new Error("Deepgram transcription failed.");
  }

  const payload = (await response.json()) as {
    results?: {
      channels?: Array<{
        alternatives?: Array<{ confidence?: number; transcript?: string }>;
      }>;
    };
  };

  return normalizeDeepgramResult(payload);
}

function normalizeDeepgramResult(payload: {
  results?: {
    channels?: Array<{
      alternatives?: Array<{ confidence?: number; transcript?: string }>;
    }>;
  };
}) {
  const alternative = payload.results?.channels?.[0]?.alternatives?.[0];
  return {
    confidence: alternative?.confidence ?? 0,
    transcript: alternative?.transcript?.trim() ?? "",
  } satisfies DeepgramResult;
}

export async function scoreLessonWithOpenAi(input: {
  deepgram: DeepgramResult;
  lesson: CourseLesson;
  openAiKey: string;
  openAiModel: string;
  slug: CourseSlug;
}) {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    body: JSON.stringify(buildOpenAiBody(input)),
    headers: {
      Authorization: `Bearer ${input.openAiKey}`,
      "Content-Type": "application/json",
    },
    method: "POST",
  });

  if (!response.ok) {
    throw new Error("OpenAI lesson scoring failed.");
  }

  const payload = (await response.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };

  return normalizeOpenAiScorecard(payload);
}

function buildOpenAiBody(input: {
  deepgram: DeepgramResult;
  lesson: CourseLesson;
  openAiModel: string;
  slug: CourseSlug;
}) {
  const support = getSpeechSupport(input.slug);
  return {
    model: input.openAiModel,
    response_format: { type: "json_object" },
    messages: [
      {
        role: "system",
        content: [
          "You are a strict but encouraging speaking evaluator for a premium language-learning product.",
          "Return JSON only with pronunciationScore, accuracyScore, fluencyScore, coachingFeedback, matchedExpectedPhrase, shouldAdvance.",
          "Scores must feel professional and stable, not random.",
          "This learner is a beginner, so close phonetic attempts should not be punished harshly.",
          "Any overall result at 75 or above should be treated as a pass and shouldAdvance true.",
          "For Japanese, accept near beginner-English renderings when they are clearly close to the target sound.",
          "Use this scale:",
          "85-100: clear, natural, and target-faithful.",
          "70-84: understandable with minor issues.",
          "50-69: partly correct but noticeable mistakes.",
          "0-49: target missed significantly.",
          "Do not give extreme low scores for near-correct beginner attempts.",
          `Coaching feedback must be short, specific, professional, and written in ${support.feedbackLanguage}.`,
        ].join(" "),
      },
      {
        role: "user",
        content: JSON.stringify({
          acceptableResponses: input.lesson.acceptableResponses,
          confidence: input.deepgram.confidence,
          language: support.label,
          learnerGoal: input.lesson.replyPrompt,
          lessonPhrase: input.lesson.demoPhrase,
          transcript: input.deepgram.transcript,
        }),
      },
    ],
  };
}

function normalizeOpenAiScorecard(payload: {
  choices?: Array<{ message?: { content?: string } }>;
}) {
  const content = payload.choices?.[0]?.message?.content ?? "{}";
  const parsed = JSON.parse(content) as Partial<OpenAiScorecard>;

  return {
    accuracyScore: clampScore(parsed.accuracyScore),
    coachingFeedback:
      parsed.coachingFeedback ??
      "Good attempt. Keep the rhythm steady and try one cleaner repetition.",
    fluencyScore: clampScore(parsed.fluencyScore),
    matchedExpectedPhrase: Boolean(parsed.matchedExpectedPhrase),
    pronunciationScore: clampScore(parsed.pronunciationScore),
    shouldAdvance: Boolean(parsed.shouldAdvance),
  } satisfies OpenAiScorecard;
}

function clampScore(value: number | undefined) {
  const safeValue = Number.isFinite(value) ? Number(value) : 0;
  return Math.max(0, Math.min(100, Math.round(safeValue)));
}

export function buildLessonEvaluation(
  deepgram: DeepgramResult,
  scorecard: OpenAiScorecard,
  lesson?: Pick<CourseLesson, "acceptableResponses" | "demoPhrase">,
  slug: CourseSlug = "english",
) {
  const calibrated = lesson
    ? calibrateScorecard(scorecard, deepgram, lesson, slug)
    : scorecard;

  return {
    ...calibrated,
    deepgramConfidence: Number(deepgram.confidence.toFixed(2)),
    transcript: deepgram.transcript,
  } satisfies LessonEvaluation;
}

function calibrateScorecard(
  scorecard: OpenAiScorecard,
  deepgram: DeepgramResult,
  lesson: Pick<CourseLesson, "acceptableResponses" | "demoPhrase">,
  slug: CourseSlug,
) {
  const band = getScoreBand(deepgram.transcript, deepgram.confidence, lesson, slug);
  if (band.shouldAdvance) {
    return buildDeterministicPass(scorecard, lesson.demoPhrase, slug, band);
  }

  const overall = Math.round(
    (Math.max(scorecard.pronunciationScore, band.pronunciationScore) +
      Math.max(scorecard.accuracyScore, band.accuracyScore) +
      Math.max(scorecard.fluencyScore, band.fluencyScore)) /
      3,
  );
  return {
    accuracyScore: Math.max(scorecard.accuracyScore, band.accuracyScore),
    coachingFeedback: fallbackCoaching(scorecard.coachingFeedback, lesson.demoPhrase, slug, false),
    fluencyScore: Math.max(scorecard.fluencyScore, band.fluencyScore),
    matchedExpectedPhrase:
      scorecard.matchedExpectedPhrase || band.matchedExpectedPhrase,
    pronunciationScore: Math.max(
      scorecard.pronunciationScore,
      band.pronunciationScore,
    ),
    shouldAdvance: scorecard.shouldAdvance || band.shouldAdvance || overall >= 75,
  } satisfies OpenAiScorecard;
}

function buildDeterministicPass(
  scorecard: OpenAiScorecard,
  phrase: string,
  slug: CourseSlug,
  band: ReturnType<typeof getScoreBand>,
) {
  return {
    accuracyScore: Math.max(scorecard.accuracyScore, band.accuracyScore),
    coachingFeedback: fallbackCoaching(scorecard.coachingFeedback, phrase, slug, true),
    fluencyScore: Math.max(scorecard.fluencyScore, band.fluencyScore),
    matchedExpectedPhrase: true,
    pronunciationScore: Math.max(scorecard.pronunciationScore, band.pronunciationScore),
    shouldAdvance: true,
  } satisfies OpenAiScorecard;
}

function getScoreBand(
  transcript: string,
  confidence: number,
  lesson: Pick<CourseLesson, "acceptableResponses" | "demoPhrase">,
  slug: CourseSlug,
) {
  if (!transcript.trim()) {
    return emptyScoreBand();
  }
  const band = buildSpeechScoreBand(
    slug,
    transcript,
    [lesson.demoPhrase, ...lesson.acceptableResponses],
    confidence,
  );
  return createScoreBand(
    band.pronunciationScore,
    band.accuracyScore,
    band.fluencyScore,
    band.matchedExpectedPhrase,
    band.shouldAdvance,
  );
}

function emptyScoreBand() {
  return createScoreBand(0, 0, 0, false, false);
}

function createScoreBand(
  pronunciationScore: number,
  accuracyScore: number,
  fluencyScore: number,
  matchedExpectedPhrase: boolean,
  shouldAdvance: boolean,
) {
  return {
    accuracyScore,
    fluencyScore,
    matchedExpectedPhrase,
    pronunciationScore,
    shouldAdvance,
  };
}

function fallbackCoaching(
  feedback: string,
  phrase: string,
  slug: CourseSlug,
  passed: boolean,
) {
  if (slug !== "japanese" && feedback.trim()) {
    return feedback;
  }

  if (slug === "japanese") {
    return passed
      ? `いいですね。『${phrase}』にかなり近いです。このまま次へ進みましょう。`
      : `おしいです。『${phrase}』に近づいています。母音をはっきり、もう一回ゆっくり言ってみましょう。`;
  }

  if (slug === "german") {
    return passed
      ? `Gut gemacht. Das kommt dem Zielwort schon sehr nahe.`
      : `Fast richtig. Sprich es noch einmal langsamer und klarer.`;
  }

  if (slug === "spanish") {
    return passed
      ? "Muy bien. Ya suena muy cerca de la palabra objetivo."
      : "Casi. Dilo otra vez un poco mas despacio y con vocales claras.";
  }

  if (slug === "french") {
    return passed
      ? "Tres bien. C'est deja tres proche du mot cible."
      : "Presque. Redis-le plus lentement avec des voyelles plus nettes.";
  }

  return passed
    ? "Good job. That is close enough to the target phrase to move on."
    : "Close attempt. Try it once more with a slower, cleaner sound.";
}
