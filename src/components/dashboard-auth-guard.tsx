"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

function GuardSplash() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-[linear-gradient(180deg,#071011_0%,#091416_100%)] px-6 text-stone-100">
      <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.04] px-6 py-5 text-sm text-stone-300">
        Checking your session...
      </div>
    </div>
  );
}

export function DashboardAuthGuard({
  children,
}: {
  children: React.ReactNode;
}) {
  const [ready, setReady] = useState(false);
  const router = useRouter();

  useEffect(() => {
    if (!hasSupabaseEnv()) {
      router.replace("/auth");
      return;
    }

    const supabase = getSupabaseBrowserClient();

    supabase.auth.getSession().then(({ data }) => {
      if (!data.session) {
        router.replace("/auth");
        return;
      }

      setReady(true);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === "SIGNED_OUT" || !session) {
        router.replace("/auth");
        return;
      }

      setReady(true);
    });

    return () => subscription.unsubscribe();
  }, [router]);

  if (!ready) {
    return <GuardSplash />;
  }

  return <>{children}</>;
}
