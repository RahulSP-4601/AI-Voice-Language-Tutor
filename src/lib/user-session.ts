import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

export type AccountProfile = {
  email: string;
  initials: string;
  name: string;
  provider: string;
  userId: string;
};

type AuthUser = {
  app_metadata?: { provider?: string };
  email?: string;
  id?: string;
  user_metadata?: { full_name?: string; name?: string };
};

export function getGuestId() {
  return "guest-user";
}

export function getInitials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

export function fallbackAccountProfile() {
  return {
    email: "No session email",
    initials: "GL",
    name: "Guest learner",
    provider: "Guest session",
    userId: getGuestId(),
  } satisfies AccountProfile;
}

export function buildAccountProfile(user?: AuthUser) {
  const fallback = fallbackAccountProfile();
  const name =
    user?.user_metadata?.full_name ??
    user?.user_metadata?.name ??
    user?.email ??
    fallback.name;

  return {
    email: user?.email ?? fallback.email,
    initials: getInitials(name) || fallback.initials,
    name,
    provider: formatProvider(user?.app_metadata?.provider),
    userId: user?.id ?? fallback.userId,
  } satisfies AccountProfile;
}

export async function resolveAccountProfile() {
  if (!hasSupabaseEnv()) {
    return fallbackAccountProfile();
  }

  const supabase = getSupabaseBrowserClient();
  const { data } = await supabase.auth.getUser();
  return buildAccountProfile(data.user ?? undefined);
}

function formatProvider(value?: string) {
  if (!value) {
    return fallbackAccountProfile().provider;
  }

  return value.charAt(0).toUpperCase() + value.slice(1);
}
