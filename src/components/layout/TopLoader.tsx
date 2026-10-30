"use client";

import { useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";

function isInternalNavigation(anchor: HTMLAnchorElement, event: MouseEvent): boolean {
  if (event.defaultPrevented || event.button !== 0) return false;
  if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return false;
  if (anchor.target && anchor.target !== "_self") return false;
  const href = anchor.getAttribute("href");
  if (!href || href.startsWith("#")) return false;
  const url = new URL(anchor.href, window.location.href);
  if (url.origin !== window.location.origin) return false;
  return (
    url.pathname !== window.location.pathname ||
    url.search !== window.location.search
  );
}

/**
 * Shows a thin progress bar as soon as an in-app link is clicked.
 * The bar finishes when the next page pathname is ready.
 * @returns The bar, or nothing while idle.
 */
export function TopLoader() {
  const pathname = usePathname();
  const [progress, setProgress] = useState(0);
  const pending = useRef(false);

  useEffect(() => {
    const onClick = (event: MouseEvent) => {
      const target = event.target;
      if (!(target instanceof Element)) return;
      const anchor = target.closest("a");
      if (!(anchor instanceof HTMLAnchorElement)) return;
      if (!isInternalNavigation(anchor, event)) return;
      pending.current = true;
      setProgress(14);
    };
    document.addEventListener("click", onClick, true);
    return () => document.removeEventListener("click", onClick, true);
  }, []);

  useEffect(() => {
    if (progress <= 0 || progress >= 100) return;
    const timer = window.setTimeout(() => {
      setProgress((value) => (value >= 100 ? value : Math.min(90, value + 8)));
    }, 180);
    return () => window.clearTimeout(timer);
  }, [progress]);

  useEffect(() => {
    if (!pending.current) return;
    pending.current = false;
    setProgress(100);
    const timer = window.setTimeout(() => setProgress(0), 220);
    return () => window.clearTimeout(timer);
  }, [pathname]);

  if (progress <= 0) return null;

  return (
    <div
      aria-hidden="true"
      className="pointer-events-none fixed inset-x-0 top-0 z-50 h-0.5 bg-[#d7eee3]"
    >
      <div
        className="h-full bg-[#146c43] transition-[width] duration-200 ease-out"
        style={{ width: `${progress}%` }}
      />
    </div>
  );
}
