"use client";

import { useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

type AuthMode = "signup" | "login";

function getRedirectTarget() {
  if (typeof window === "undefined") {
    return "";
  }

  return `${window.location.origin}/dashboard`;
}

async function startGoogleAuth() {
  const supabase = getSupabaseBrowserClient();
  const result = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: getRedirectTarget(),
      queryParams: {
        access_type: "offline",
        prompt: "select_account",
      },
    },
  });

  if (result.error) {
    throw result.error;
  }
}

function AuthButton(props: {
  busyMode: AuthMode | null;
  label: string;
  loadingLabel: string;
  mode: AuthMode;
  onClick: (mode: AuthMode) => void;
  secondary?: boolean;
}) {
  const className = props.secondary
    ? "w-full rounded-full border border-white/15 bg-white/5 px-5 py-4 text-base font-medium text-white transition hover:border-white/30 hover:bg-white/10 disabled:cursor-not-allowed disabled:opacity-70"
    : "w-full rounded-full bg-[linear-gradient(135deg,#f7c874_0%,#ff8c69_100%)] px-5 py-4 text-base font-semibold text-slate-950 transition hover:scale-[1.01] disabled:cursor-not-allowed disabled:opacity-70";

  return (
    <button
      type="button"
      onClick={() => props.onClick(props.mode)}
      disabled={props.busyMode !== null}
      className={className}
    >
      {props.busyMode === props.mode ? props.loadingLabel : props.label}
    </button>
  );
}

function AuthStatus({
  envReady,
  message,
}: {
  envReady: boolean;
  message: string | null;
}) {
  return (
    <div className="mt-6 rounded-[1.3rem] border border-white/8 bg-black/20 p-4 text-sm leading-7 text-stone-300">
      <p>
        {envReady
          ? "Supabase public environment is available. Clicking a button starts Google OAuth."
          : "Supabase OAuth is not configured yet in this local environment, so the buttons show setup-safe messaging instead of failing silently."}
      </p>
      {message ? <p className="mt-3 text-amber-200">{message}</p> : null}
    </div>
  );
}

function AuthHeader() {
  return (
    <>
      <p className="text-sm uppercase tracking-[0.35em] text-amber-200">
        Access
      </p>
      <h2 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white">
        Continue with Google
      </h2>
      <p className="mt-4 text-sm leading-8 text-stone-300">
        Users should enter with one familiar action, then continue into
        onboarding and the first course dashboard.
      </p>
    </>
  );
}

export function AuthCard() {
  const [busyMode, setBusyMode] = useState<AuthMode | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const envReady = hasSupabaseEnv();

  async function handleAuth(mode: AuthMode) {
    if (!envReady) {
      setMessage("Add Supabase public env values before Google auth can start.");
      return;
    }

    setBusyMode(mode);
    setMessage(null);

    try {
      await startGoogleAuth();
    } catch (error) {
      const fallback = "Google auth could not start. Check Supabase OAuth setup.";
      setMessage(error instanceof Error ? error.message : fallback);
      setBusyMode(null);
    }
  }

  return (
    <section className="rounded-[2rem] border border-white/10 bg-[#0d1416]/90 p-6 shadow-[0_30px_100px_rgba(0,0,0,0.35)] backdrop-blur">
      <div className="rounded-[1.6rem] border border-white/10 bg-white/[0.03] p-6">
        <AuthHeader />
        <div className="mt-8 space-y-4">
          <AuthButton
            mode="signup"
            label="Sign up with Google"
            loadingLabel="Opening Google signup..."
            busyMode={busyMode}
            onClick={handleAuth}
          />
          <AuthButton
            mode="login"
            label="Log in with Google"
            loadingLabel="Opening Google login..."
            busyMode={busyMode}
            onClick={handleAuth}
            secondary
          />
        </div>
        <AuthStatus envReady={envReady} message={message} />
      </div>
    </section>
  );
}
