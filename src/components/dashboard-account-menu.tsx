"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import { useAccountProfile } from "@/components/use-account-profile";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

function MenuLink(props: { href: string; label: string; sublabel: string }) {
  return (
    <Link
      href={props.href}
      className="block rounded-2xl border border-white/10 bg-[#131a1d] px-4 py-3 transition hover:border-white/20 hover:bg-[#182126]"
    >
      <p className="text-sm font-medium text-white">{props.label}</p>
      <p className="mt-1 text-xs text-stone-400">{props.sublabel}</p>
    </Link>
  );
}

function AccountTrigger(props: {
  initials: string;
  isOpen: boolean;
  name: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={props.onClick}
      className="flex items-center gap-3 rounded-full border border-white/12 bg-[#101719] px-3 py-2 text-left transition hover:border-white/20 hover:bg-[#162023]"
    >
      <span className="flex h-10 w-10 items-center justify-center rounded-full bg-[linear-gradient(135deg,#8f9cf9_0%,#d0d5ff_100%)] text-sm font-semibold text-slate-950">
        {props.initials}
      </span>
      <span>
        <span className="block text-sm font-medium text-white">{props.name}</span>
        <span className="block text-xs text-stone-400">My account details</span>
      </span>
      <span className="text-stone-400">{props.isOpen ? "▴" : "▾"}</span>
    </button>
  );
}

function AccountPanel(props: {
  email: string;
  name: string;
  onLogout: () => Promise<void>;
}) {
  return (
    <div className="absolute right-0 top-full z-50 mt-3 w-[20rem] rounded-[1.5rem] border border-white/12 bg-[#0b1113] p-4 shadow-[0_28px_90px_rgba(0,0,0,0.55)]">
      <div className="rounded-[1.2rem] border border-white/10 bg-[#131a1d] p-4">
        <p className="text-sm font-medium text-white">{props.name}</p>
        <p className="mt-1 text-xs text-stone-400">{props.email}</p>
      </div>
      <div className="mt-4 space-y-3">
        <MenuLink
          href="/dashboard/profile"
          label="Profile"
          sublabel="See your name and personal details"
        />
        <MenuLink
          href="/dashboard/account"
          label="Account"
          sublabel="See your learning progress so far"
        />
        <button
          type="button"
          onClick={props.onLogout}
          className="w-full rounded-2xl border border-red-400/20 bg-[#2a1618] px-4 py-3 text-left transition hover:border-red-400/35 hover:bg-[#34191c]"
        >
          <p className="text-sm font-medium text-red-200">Logout</p>
          <p className="mt-1 text-xs text-red-200/70">
            End the current session and return home
          </p>
        </button>
      </div>
    </div>
  );
}

function useCloseOnOutsideClick(
  menuRef: React.RefObject<HTMLDivElement | null>,
  setIsOpen: React.Dispatch<React.SetStateAction<boolean>>,
) {
  useEffect(() => {
    function handleOutsideClick(event: MouseEvent) {
      if (!menuRef.current?.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }

    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, [menuRef, setIsOpen]);
}

export function DashboardAccountMenu() {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const envReady = hasSupabaseEnv();
  const { profile: account } = useAccountProfile();
  const summary = useMemo(
    () => ({ initials: account.initials, name: account.name }),
    [account],
  );

  useCloseOnOutsideClick(menuRef, setIsOpen);

  async function handleLogout() {
    if (envReady) {
      const supabase = getSupabaseBrowserClient();
      await supabase.auth.signOut();
    }

    setIsOpen(false);
    window.location.replace("/auth");
  }

  return (
    <div ref={menuRef} className="relative z-50 self-start sm:self-auto">
      <AccountTrigger
        initials={summary.initials}
        name={summary.name}
        isOpen={isOpen}
        onClick={() => setIsOpen((value) => !value)}
      />
      {isOpen ? (
        <AccountPanel
          name={account.name}
          email={account.email}
          onLogout={handleLogout}
        />
      ) : null}
    </div>
  );
}
