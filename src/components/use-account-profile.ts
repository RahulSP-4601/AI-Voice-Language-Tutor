"use client";

import { useEffect, useState } from "react";
import {
  fallbackAccountProfile,
  resolveAccountProfile,
  type AccountProfile,
} from "@/lib/user-session";

export function useAccountProfile() {
  const [profile, setProfile] = useState<AccountProfile>(fallbackAccountProfile());
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let active = true;

    resolveAccountProfile().then((value) => {
      if (!active) {
        return;
      }

      setProfile(value);
      setReady(true);
    });

    return () => {
      active = false;
    };
  }, []);

  return { profile, ready };
}
