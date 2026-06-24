"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { getSupabaseBrowserClient } from "@/lib/supabase/client";
import { hasSupabaseEnv } from "@/lib/supabase/env";

type AccountState = {
  email: string;
  initials: string;
  name: string;
};

function fallbackAccount(): AccountState {
  return {
    email: "No session email",
    initials: "RP",
    name: "Rahul Panchal",
  };
}

function getInitials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

function buildAccountState(user: {
  email?: string;
  user_metadata?: { full_name?: string; name?: string };
}) {
  const name =
    user.user_metadata?.full_name ??
    user.user_metadata?.name ??
    user.email ??
    fallbackAccount().name;

  return {
    email: user.email ?? fallbackAccount().email,
    initials: getInitials(name) || fallbackAccount().initials,
    name,
  };
}

function MenuLink(props: { href: string; label: string; sublabel: string }) {
  return (
    <Link
      href={props.href}
      className="block rounded-2xl border border-white/8 bg-black/20 px-4 py-3 transition hover:border-white/15 hover:bg-black/30"
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
      className="flex items-center gap-3 rounded-full border border-white/12 bg-black/20 px-3 py-2 text-left transition hover:border-white/20 hover:bg-black/30"
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
    <div className="absolute right-0 z-20 mt-3 w-[20rem] rounded-[1.5rem] border border-white/10 bg-[#0c1214]/96 p-4 shadow-[0_24px_70px_rgba(0,0,0,0.35)] backdrop-blur">
      <div className="rounded-[1.2rem] border border-white/8 bg-white/[0.03] p-4">
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
          sublabel="See purchased courses so far"
        />
        <button
          type="button"
          onClick={props.onLogout}
          className="w-full rounded-2xl border border-red-400/20 bg-red-500/10 px-4 py-3 text-left transition hover:border-red-400/35 hover:bg-red-500/15"
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

function useAccountState(envReady: boolean) {
  const [account, setAccount] = useState<AccountState>(fallbackAccount());
  useEffect(() => {
    if (!envReady) {
      return undefined;
    }

    const supabase = getSupabaseBrowserClient();
    supabase.auth.getUser().then(({ data }) => {
      if (data.user) {
        setAccount(buildAccountState(data.user));
      }
    });
  }, [envReady]);

  return account;
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
  const router = useRouter();
  const envReady = hasSupabaseEnv();
  const account = useAccountState(envReady);
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

    router.push("/");
    router.refresh();
  }

  return (
    <div ref={menuRef} className="relative self-start sm:self-auto">
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
