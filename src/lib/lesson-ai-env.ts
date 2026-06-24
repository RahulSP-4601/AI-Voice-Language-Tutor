function readEnvValue(value: string | undefined) {
  return typeof value === "string" && value.trim().length > 0;
}

function assertEnvValue(
  value: string | undefined,
  envName: string,
): asserts value is string {
  if (!readEnvValue(value)) {
    throw new Error(`Missing required environment variable: ${envName}`);
  }
}

export function getLessonAiEnv() {
  const openAiKey = process.env.OPENAI_API_KEY;
  const openAiModel = process.env.OPENAI_MODEL;
  const deepgramKey = process.env.DEEPGRAM_API_KEY;
  const deepgramModel = process.env.DEEPGRAM_MODEL;

  assertEnvValue(openAiKey, "OPENAI_API_KEY");
  assertEnvValue(openAiModel, "OPENAI_MODEL");
  assertEnvValue(deepgramKey, "DEEPGRAM_API_KEY");
  assertEnvValue(deepgramModel, "DEEPGRAM_MODEL");

  return {
    deepgramKey: deepgramKey.trim(),
    deepgramModel: deepgramModel.trim(),
    openAiKey: openAiKey.trim(),
    openAiModel: openAiModel.trim(),
  };
}
