import { NextResponse } from "next/server";
import { hasLessonAiEnv } from "@/lib/runtime-guards";
import { hasSupabaseEnv, hasSupabaseServiceRoleEnv } from "@/lib/supabase/env";

export function GET() {
  const supabaseConfigured = hasSupabaseEnv();
  const rateLimitConfigured = hasSupabaseServiceRoleEnv();
  const lessonAiConfigured = hasLessonAiEnv();
  const launchReady = supabaseConfigured && lessonAiConfigured && rateLimitConfigured;

  return NextResponse.json({
    checks: {
      lessonAiConfigured,
      rateLimitConfigured,
      supabaseConfigured,
    },
    launchReady,
    ok: true,
    ready: launchReady,
    service: "pronouncly",
    timestamp: new Date().toISOString(),
  });
}
