import { createClient } from "@supabase/supabase-js";
import { getSupabaseEnv, getSupabaseServiceRoleEnv } from "@/lib/supabase/env";

export function getSupabaseServerClient() {
  const { anonKey, url } = getSupabaseEnv();
  return createClient(url, anonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

export function getSupabaseAdminClient() {
  const { serviceRoleKey, url } = getSupabaseServiceRoleEnv();
  return createClient(url, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
