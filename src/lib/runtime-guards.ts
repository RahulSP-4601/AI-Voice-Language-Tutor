function isPresent(value: string | undefined) {
  return typeof value === "string" && value.trim().length > 0;
}

export function hasLessonAiEnv() {
  return (
    isPresent(process.env.OPENAI_API_KEY) &&
    isPresent(process.env.OPENAI_MODEL) &&
    isPresent(process.env.DEEPGRAM_API_KEY) &&
    isPresent(process.env.DEEPGRAM_MODEL)
  );
}

export function isAbortError(error: unknown) {
  return error instanceof Error && error.name === "AbortError";
}

export async function fetchWithTimeout(
  input: Parameters<typeof fetch>[0],
  init: Parameters<typeof fetch>[1] & { timeoutMs?: number } = {},
) {
  const { timeoutMs = 15000, ...rest } = init;
  return fetch(input, {
    ...rest,
    signal: AbortSignal.timeout(timeoutMs),
  });
}
