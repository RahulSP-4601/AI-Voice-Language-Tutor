import { type CourseLesson, type CourseSlug, type LessonEvaluation } from "@/lib/course-definitions";

type DeepgramResult = {
  confidence: number;
  transcript: string;
};

type OpenAiScorecard = Omit<LessonEvaluation, "deepgramConfidence" | "transcript">;

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
        content:
          "You score language-learning speech attempts. Return JSON only with pronunciationScore, accuracyScore, fluencyScore, coachingFeedback, matchedExpectedPhrase, shouldAdvance.",
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
) {
  return {
    ...scorecard,
    deepgramConfidence: Number(deepgram.confidence.toFixed(2)),
    transcript: deepgram.transcript,
  } satisfies LessonEvaluation;
}
