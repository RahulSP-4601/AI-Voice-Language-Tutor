import { NextResponse } from "next/server";
import { hasLessonAiEnv } from "@/lib/runtime-guards";
import { hasSupabaseEnv } from "@/lib/supabase/env";

export function GET() {
  const supabaseConfigured = hasSupabaseEnv();
  const lessonAiConfigured = hasLessonAiEnv();
  const launchReady = supabaseConfigured && lessonAiConfigured;

  return NextResponse.json({
    checks: {
      lessonAiConfigured,
      supabaseConfigured,
    },
    launchReady,
    ok: true,
    ready: launchReady,
    service: "pronouncly",
    timestamp: new Date().toISOString(),
  });
}
