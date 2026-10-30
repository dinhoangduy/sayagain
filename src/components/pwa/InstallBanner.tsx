"use client";

import Image from "next/image";
import { useEffect, useState, useSyncExternalStore } from "react";
import { Check, Copy, Download, ExternalLink, Share, X } from "lucide-react";
import {
  checkBrowserStandalone,
  detectInstallBannerMode,
  INSTALL_DISMISS_STORAGE_KEY,
  isDismissCooldownActive,
} from "@/lib/pwa/platform";

interface BeforeInstallPromptEvent extends Event {
  readonly platforms: string[];
  readonly userChoice: Promise<{
    outcome: "accepted" | "dismissed";
    platform: string;
  }>;
  prompt(): Promise<void>;
}

const emptySubscribe = () => () => {};

function subscribeStandaloneMode(onStoreChange: () => void): () => void {
  if (typeof window === "undefined") {
    return () => {};
  }
  const mq = window.matchMedia?.("(display-mode: standalone)");
  mq?.addEventListener?.("change", onStoreChange);
  return () => {
    mq?.removeEventListener?.("change", onStoreChange);
  };
}

export function InstallBanner() {
  const isClient = useSyncExternalStore(
    emptySubscribe,
    () => true,
    () => false
  );
  const isStandalone = useSyncExternalStore(
    subscribeStandaloneMode,
    () => checkBrowserStandalone(),
    () => false
  );

  const [deferredPrompt, setDeferredPrompt] =
    useState<BeforeInstallPromptEvent | null>(null);
  const [installedConfirmed, setInstalledConfirmed] = useState(false);
  const [, setDismissRevision] = useState(0);
  const [showInstructions, setShowInstructions] = useState(false);
  const [copiedLink, setCopiedLink] = useState(false);
  const [prompting, setPrompting] = useState(false);

  useEffect(() => {
    const handleBeforeInstallPrompt = (event: Event) => {
      event.preventDefault();
      setDeferredPrompt(event as BeforeInstallPromptEvent);
    };

    const handleAppInstalled = () => {
      setDeferredPrompt(null);
      setShowInstructions(false);
      setInstalledConfirmed(true);
    };

    const handleResetBanner = () => {
      window.localStorage.removeItem(INSTALL_DISMISS_STORAGE_KEY);
      setDismissRevision((rev) => rev + 1);
    };

    window.addEventListener("beforeinstallprompt", handleBeforeInstallPrompt);
    window.addEventListener("appinstalled", handleAppInstalled);
    window.addEventListener("sayagain:reset-install-banner", handleResetBanner);

    return () => {
      window.removeEventListener(
        "beforeinstallprompt",
        handleBeforeInstallPrompt
      );
      window.removeEventListener("appinstalled", handleAppInstalled);
      window.removeEventListener(
        "sayagain:reset-install-banner",
        handleResetBanner
      );
    };
  }, []);

  if (!isClient || installedConfirmed) {
    return null;
  }

  const storedDismiss = window.localStorage.getItem(
    INSTALL_DISMISS_STORAGE_KEY
  );
  if (isDismissCooldownActive(storedDismiss)) {
    return null;
  }

  const mode = detectInstallBannerMode({
    userAgent: window.navigator.userAgent,
    isStandalone,
    hasBeforeInstallPrompt: deferredPrompt !== null,
    maxTouchPoints: window.navigator.maxTouchPoints ?? 0,
  });

  if (mode === "hidden") {
    return null;
  }

  const handleDismiss = () => {
    window.localStorage.setItem(
      INSTALL_DISMISS_STORAGE_KEY,
      String(Date.now())
    );
    setShowInstructions(false);
    setDismissRevision((rev) => rev + 1);
  };

  const handleNativeInstall = async () => {
    if (!deferredPrompt || prompting) {
      return;
    }

    setPrompting(true);
    try {
      await deferredPrompt.prompt();
      await deferredPrompt.userChoice;
      setDeferredPrompt(null);
    } catch {
      setDeferredPrompt(null);
    } finally {
      setPrompting(false);
    }
  };

  const handleCopyCurrentUrl = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setCopiedLink(true);
      window.setTimeout(() => setCopiedLink(false), 2500);
    } catch {
      setShowInstructions(true);
    }
  };

  return (
    <div
      role="region"
      aria-label="Install SayAgain app"
      className="w-full border-b border-[#c8e3d2] bg-[#eaf5ee] text-[#132019]"
    >
      <div className="mx-auto flex max-w-xl items-center justify-between gap-2.5 px-3.5 py-2">
        <div className="flex min-w-0 items-center gap-2.5">
          <Image
            src="/logo.png"
            alt=""
            width={28}
            height={28}
            className="h-7 w-7 shrink-0 rounded-full"
          />
          <div className="min-w-0">
            <p className="truncate text-xs font-semibold leading-tight text-[#132019] sm:text-[13px]">
              {mode === "in-app-browser"
                ? "Open in browser to install SayAgain"
                : "Add SayAgain to your home screen"}
            </p>
            <p className="truncate text-[11px] leading-tight text-[#435b4d]">
              {mode === "chromium-prompt" && "Quick daily speaking review"}
              {mode === "ios-safari" && "Launch full-screen from iPhone/iPad"}
              {mode === "ios-other-browser" && "Requires Safari on iOS"}
              {mode === "in-app-browser" &&
                "In-app browsers block home screen apps"}
            </p>
          </div>
        </div>

        <div className="flex shrink-0 items-center gap-1">
          {mode === "chromium-prompt" ? (
            <button
              type="button"
              onClick={() => void handleNativeInstall()}
              disabled={prompting}
              className="inline-flex min-h-[34px] cursor-pointer items-center gap-1.5 rounded-lg bg-[#146c43] px-3 py-1.5 text-xs font-semibold text-white transition hover:bg-[#0f5635] disabled:opacity-60"
            >
              <Download className="h-3.5 w-3.5" aria-hidden="true" />
              <span>{prompting ? "Opening…" : "Install"}</span>
            </button>
          ) : (
            <button
              type="button"
              onClick={() => setShowInstructions((prev) => !prev)}
              aria-expanded={showInstructions}
              className="inline-flex min-h-[34px] cursor-pointer items-center gap-1 rounded-lg border border-[#9fd0b2] bg-white px-2.5 py-1.5 text-xs font-semibold text-[#146c43] transition hover:bg-[#f3faf5]"
            >
              {mode === "in-app-browser" ? (
                <>
                  <ExternalLink className="h-3.5 w-3.5" aria-hidden="true" />
                  <span>Open guide</span>
                </>
              ) : (
                <>
                  <Share className="h-3.5 w-3.5" aria-hidden="true" />
                  <span>How to add</span>
                </>
              )}
            </button>
          )}

          <button
            type="button"
            onClick={handleDismiss}
            aria-label="Dismiss install banner"
            className="inline-flex h-8 w-8 cursor-pointer items-center justify-center rounded-lg text-[#435b4d] transition hover:bg-[#d8ede0] hover:text-[#132019]"
          >
            <X className="h-4 w-4" aria-hidden="true" />
          </button>
        </div>
      </div>

      {showInstructions && mode === "ios-safari" && (
        <div className="border-t border-[#c8e3d2] bg-[#f4faf6] px-3.5 py-2.5 text-xs text-[#24382c]">
          <div className="mx-auto max-w-xl space-y-1">
            <p className="font-medium">
              1. Tap the{" "}
              <span className="font-semibold text-[#146c43]">Share</span> button
              in Safari’s toolbar.
            </p>
            <p className="font-medium">
              2. Scroll down and tap{" "}
              <span className="font-semibold text-[#146c43]">
                Add to Home Screen
              </span>{" "}
              (keep <em>Open as Web App</em> enabled if shown).
            </p>
          </div>
        </div>
      )}

      {showInstructions && mode === "ios-other-browser" && (
        <div className="border-t border-[#c8e3d2] bg-[#f4faf6] px-3.5 py-2.5 text-xs text-[#24382c]">
          <div className="mx-auto flex max-w-xl items-center justify-between gap-2">
            <p>
              Open this page in <strong>Safari</strong>, then tap{" "}
              <strong>Share → Add to Home Screen</strong>.
            </p>
            <button
              type="button"
              onClick={() => void handleCopyCurrentUrl()}
              className="inline-flex shrink-0 cursor-pointer items-center gap-1 rounded-md border border-[#b9dcc7] bg-white px-2.5 py-1 text-xs font-semibold text-[#146c43]"
            >
              {copiedLink ? (
                <>
                  <Check className="h-3.5 w-3.5" />
                  <span>Copied</span>
                </>
              ) : (
                <>
                  <Copy className="h-3.5 w-3.5" />
                  <span>Copy link</span>
                </>
              )}
            </button>
          </div>
        </div>
      )}

      {showInstructions && mode === "in-app-browser" && (
        <div className="border-t border-[#c8e3d2] bg-[#f4faf6] px-3.5 py-2.5 text-xs text-[#24382c]">
          <div className="mx-auto flex max-w-xl items-center justify-between gap-2">
            <p>
              Tap the <strong>⋯</strong> or <strong>Share</strong> menu in the
              corner and choose <strong>Open in Browser</strong> (Chrome or
              Safari).
            </p>
            <button
              type="button"
              onClick={() => void handleCopyCurrentUrl()}
              className="inline-flex shrink-0 cursor-pointer items-center gap-1 rounded-md border border-[#b9dcc7] bg-white px-2.5 py-1 text-xs font-semibold text-[#146c43]"
            >
              {copiedLink ? (
                <>
                  <Check className="h-3.5 w-3.5" />
                  <span>Copied</span>
                </>
              ) : (
                <>
                  <Copy className="h-3.5 w-3.5" />
                  <span>Copy link</span>
                </>
              )}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
