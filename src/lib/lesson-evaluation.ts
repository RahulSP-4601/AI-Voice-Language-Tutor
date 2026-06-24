import { type CourseLesson, type CourseSlug, type LessonEvaluation } from "@/lib/course-definitions";

type DeepgramResult = {
  confidence: number;
  transcript: string;
};

type OpenAiScorecard = Omit<LessonEvaluation, "deepgramConfidence" | "transcript">;
type ScoreBand = {
  accuracyScore: number;
  fluencyScore: number;
  matchedExpectedPhrase: boolean;
  pronunciationScore: number;
  shouldAdvance: boolean;
};

function getLanguageLabel(slug: CourseSlug) {
  if (slug === "japanese") return "Japanese";
  if (slug === "german") return "German";
  if (slug === "spanish") return "Spanish";
  if (slug === "french") return "French";
  return "English";
}

export async function transcribeWithDeepgram(input: {
  audioBuffer: ArrayBuffer;
  contentType: string;
  deepgramKey: string;
  deepgramModel: string;
}) {
  const response = await fetch(
    `https://api.deepgram.com/v1/listen?model=${encodeURIComponent(
      input.deepgramModel,
    )}&smart_format=true`,
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
          "Use this scale:",
          "85-100: clear, natural, and target-faithful.",
          "70-84: understandable with minor issues.",
          "50-69: partly correct but noticeable mistakes.",
          "0-49: target missed significantly.",
          "Do not give extreme low scores for near-correct beginner attempts.",
          "Coaching feedback must be short, specific, and professional.",
        ].join(" "),
      },
      {
        role: "user",
        content: JSON.stringify({
          acceptableResponses: input.lesson.acceptableResponses,
          confidence: input.deepgram.confidence,
          language: getLanguageLabel(input.slug),
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
) {
  const calibrated = lesson
    ? calibrateScorecard(scorecard, deepgram, lesson)
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
) {
  const band = getScoreBand(deepgram.transcript, deepgram.confidence, lesson);
  return {
    accuracyScore: Math.max(scorecard.accuracyScore, band.accuracyScore),
    coachingFeedback: scorecard.coachingFeedback,
    fluencyScore: Math.max(scorecard.fluencyScore, band.fluencyScore),
    matchedExpectedPhrase:
      scorecard.matchedExpectedPhrase || band.matchedExpectedPhrase,
    pronunciationScore: Math.max(
      scorecard.pronunciationScore,
      band.pronunciationScore,
    ),
    shouldAdvance: scorecard.shouldAdvance || band.shouldAdvance,
  } satisfies OpenAiScorecard;
}

function getScoreBand(
  transcript: string,
  confidence: number,
  lesson: Pick<CourseLesson, "acceptableResponses" | "demoPhrase">,
) {
  if (!transcript.trim()) {
    return emptyScoreBand();
  }

  const similarity = getBestSimilarity(transcript, [
    lesson.demoPhrase,
    ...lesson.acceptableResponses,
  ]);
  const blended = similarity * 0.85 + Math.max(confidence, 0.35) * 0.15;

  if (blended >= 0.9) {
    return createScoreBand(90, 92, 86, true, true);
  }

  if (blended >= 0.78) {
    return createScoreBand(78, 82, 72, true, true);
  }

  if (blended >= 0.62) {
    return createScoreBand(66, 70, 62, true, false);
  }

  if (blended >= 0.45) {
    return createScoreBand(52, 56, 50, false, false);
  }

  return emptyScoreBand();
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
  } satisfies ScoreBand;
}

function getBestSimilarity(transcript: string, candidates: string[]) {
  const normalizedTranscript = normalizeComparableText(transcript);
  return candidates.reduce((best, candidate) => {
    const similarity = getPhraseSimilarity(
      normalizedTranscript,
      normalizeComparableText(candidate),
    );
    return Math.max(best, similarity);
  }, 0);
}

function getPhraseSimilarity(source: string, target: string) {
  if (!source || !target) return 0;
  if (source === target) return 1;
  if (source.includes(target) || target.includes(source)) return 0.88;
  const sourceTokens = source.split(" ");
  const targetTokens = target.split(" ");
  const sharedTokens = sourceTokens.filter((token) => targetTokens.includes(token));
  const tokenScore = sharedTokens.length / Math.max(sourceTokens.length, targetTokens.length, 1);
  const bigramScore = getBigramScore(source, target);
  return Number(((tokenScore * 0.55) + (bigramScore * 0.45)).toFixed(2));
}

function normalizeComparableText(value: string) {
  return value
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function getBigramScore(source: string, target: string) {
  const sourceBigrams = toBigrams(source);
  const targetBigrams = toBigrams(target);

  if (!sourceBigrams.length || !targetBigrams.length) {
    return 0;
  }

  const targetSet = new Set(targetBigrams);
  const matches = sourceBigrams.filter((value) => targetSet.has(value)).length;
  return (2 * matches) / (sourceBigrams.length + targetBigrams.length);
}

function toBigrams(value: string) {
  if (value.length < 2) {
    return [value];
  }

  const compact = value.replace(/\s+/g, " ");
  return Array.from({ length: compact.length - 1 }, (_, index) =>
    compact.slice(index, index + 2),
  );
}
