"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookOpen, Home, Mic, Plus, Settings } from "lucide-react";

const NAV_ITEMS = [
  { href: "/", label: "Home", icon: Home },
  { href: "/review", label: "Review", icon: Mic },
  { href: "/library", label: "Library", icon: BookOpen },
  { href: "/settings", label: "Settings", icon: Settings },
] as const;

function isActiveRoute(pathname: string, href: string): boolean {
  if (href === "/") {
    return pathname === "/";
  }
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function AppHeader() {
  const pathname = usePathname();
  const importActive = pathname.startsWith("/import");

  return (
    <header className="w-full border-b border-[#dce7e0] bg-white/95 backdrop-blur-sm">
      <div className="mx-auto flex max-w-xl items-center justify-between gap-2 px-4 py-2.5">
        <Link
          href="/"
          className="inline-flex items-center gap-2 rounded-lg py-1 pr-2 focus:outline-none focus-visible:ring-2 focus-visible:ring-[#146c43]"
        >
          <span
            aria-hidden="true"
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-[#146c43] text-xs font-bold tracking-tight text-white"
          >
            SA
          </span>
          <span className="text-base font-bold tracking-tight text-[#132019]">
            SayAgain
          </span>
        </Link>

        <div className="flex items-center gap-1.5">
          <nav
            aria-label="Primary desktop"
            className="hidden items-center gap-1 sm:flex"
          >
            {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
              const active = isActiveRoute(pathname, href);
              return (
                <Link
                  key={href}
                  href={href}
                  aria-current={active ? "page" : undefined}
                  className={`inline-flex min-h-[38px] items-center gap-1.5 rounded-xl px-3 py-1.5 text-[13px] font-semibold transition ${
                    active
                      ? "bg-[#eaf5ee] text-[#146c43]"
                      : "text-[#52635a] hover:bg-[#f2f7f4] hover:text-[#132019]"
                  }`}
                >
                  <Icon className="h-3.5 w-3.5 shrink-0" aria-hidden="true" />
                  <span>{label}</span>
                </Link>
              );
            })}
          </nav>

          <Link
            href="/import"
            aria-current={importActive ? "page" : undefined}
            className={`inline-flex min-h-[38px] items-center gap-1 rounded-xl border px-3 py-1.5 text-xs font-semibold transition sm:text-[13px] ${
              importActive
                ? "border-[#146c43] bg-[#146c43] text-white"
                : "border-[#c8e3d2] bg-[#f4faf6] text-[#146c43] hover:bg-[#eaf5ee]"
            }`}
          >
            <Plus className="h-3.5 w-3.5 shrink-0" aria-hidden="true" />
            <span>Import</span>
          </Link>
        </div>
      </div>
    </header>
  );
}

export function MobileBottomNav() {
  const pathname = usePathname();

  return (
    <nav
      aria-label="Primary mobile"
      className="fixed inset-x-0 bottom-0 z-30 border-t border-[#dce7e0] bg-white/95 pb-[env(safe-area-inset-bottom)] backdrop-blur-sm sm:hidden"
    >
      <div className="mx-auto grid max-w-xl grid-cols-4 px-2 py-1">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active = isActiveRoute(pathname, href);
          return (
            <Link
              key={href}
              href={href}
              aria-current={active ? "page" : undefined}
              className={`flex min-h-[48px] flex-col items-center justify-center gap-0.5 rounded-xl px-1 py-1 text-[11px] font-semibold transition ${
                active
                  ? "text-[#146c43]"
                  : "text-[#52635a] hover:text-[#132019]"
              }`}
            >
              <Icon
                className={`h-4 w-4 shrink-0 ${
                  active ? "stroke-[2.4]" : "stroke-[2]"
                }`}
                aria-hidden="true"
              />
              <span>{label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
