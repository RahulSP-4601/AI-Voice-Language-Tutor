import { NextResponse } from "next/server";
import { type CourseSlug, isCourseSlug } from "@/lib/course-definitions";
import { getTutorSpeechModel } from "@/lib/tutor-speech";

type SpeechRequestBody = {
  slug?: string;
  text?: string;
};

function getDeepgramKey() {
  const value = process.env.DEEPGRAM_API_KEY;
  if (!value || !value.trim()) {
    throw new Error("Missing required environment variable: DEEPGRAM_API_KEY");
  }

  return value.trim();
}

function parseBody(body: SpeechRequestBody) {
  const slug = body.slug?.trim();
  const text = body.text?.trim();

  if (!slug || !isCourseSlug(slug) || !text) {
    return null;
  }

  return { slug, text };
}

async function requestDeepgramSpeech(input: { slug: CourseSlug; text: string }) {
  return fetch(
    `https://api.deepgram.com/v1/speak?model=${encodeURIComponent(
      getTutorSpeechModel(input.slug),
    )}&encoding=mp3`,
    {
      method: "POST",
      headers: {
        Authorization: `Token ${getDeepgramKey()}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ text: input.text }),
    },
  );
}

async function toSpeechResponse(response: Response) {
  if (!response.ok) {
    const errorText = await response.text();
    return NextResponse.json(
      { error: errorText || "Deepgram speech generation failed." },
      { status: 502 },
    );
  }

  const audioBuffer = await response.arrayBuffer();
  return new Response(audioBuffer, {
    headers: {
      "Cache-Control": "no-store",
      "Content-Type": response.headers.get("Content-Type") ?? "audio/mpeg",
    },
  });
}

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as SpeechRequestBody;
    const parsed = parseBody(body);

    if (!parsed) {
      return NextResponse.json(
        { error: "A valid course slug and text are required." },
        { status: 400 },
      );
    }

    return toSpeechResponse(await requestDeepgramSpeech(parsed));
  } catch (error) {
    return NextResponse.json(
      {
        error:
          error instanceof Error
            ? error.message
            : "Unable to generate tutor speech right now.",
      },
      { status: 500 },
    );
  }
}
