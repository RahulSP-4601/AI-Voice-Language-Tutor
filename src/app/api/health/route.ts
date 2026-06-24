import { NextResponse } from "next/server";
import { hasSupabaseEnv } from "@/lib/supabase/env";

export function GET() {
  return NextResponse.json({
    ok: true,
    service: "ai-voice-tutor",
    supabaseConfigured: hasSupabaseEnv(),
  });
}
