"use client";

import { useEffect } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

function clearAuthHash() {
  const cleanUrl = `${window.location.pathname}${window.location.search}`;
  window.history.replaceState({}, document.title, cleanUrl);
}

export function AuthHashCleaner() {
  useEffect(() => {
    if (!hasSupabaseEnv() || window.location.hash.length === 0) {
      return;
    }

    const supabase = getSupabaseBrowserClient();

    supabase.auth.getSession().finally(() => {
      clearAuthHash();
    });
  }, []);

  return null;
}
