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

export function hasSupabaseEnv() {
  return (
    readEnvValue(process.env.NEXT_PUBLIC_SUPABASE_URL) &&
    readEnvValue(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)
  );
}

export function getSupabaseEnv() {
  const rawUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const rawAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  assertEnvValue(rawUrl, "NEXT_PUBLIC_SUPABASE_URL");
  assertEnvValue(rawAnonKey, "NEXT_PUBLIC_SUPABASE_ANON_KEY");
  const url = rawUrl.trim();
  const anonKey = rawAnonKey.trim();
  return { url, anonKey };
}
