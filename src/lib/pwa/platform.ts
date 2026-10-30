export const INSTALL_DISMISS_STORAGE_KEY = "sayagain_install_dismissed_at";
export const DEFAULT_DISMISS_COOLDOWN_DAYS = 7;

export type InstallBannerMode =
  | "hidden"
  | "chromium-prompt"
  | "ios-safari"
  | "ios-other-browser"
  | "in-app-browser";

export interface PlatformDetectionInput {
  userAgent: string;
  isStandalone: boolean;
  hasBeforeInstallPrompt: boolean;
  maxTouchPoints?: number;
}

const IN_APP_BROWSER_REGEX =
  /\b(TikTok|musical_ly|BytedanceWebview|Instagram|FBAN|FBAV|FB_IAB|Messenger|Line\/|MicroMessenger|Snapchat|Threads|Twitter|Zalo)\b/i;

const IOS_DEVICE_REGEX = /\b(iPhone|iPad|iPod)\b/i;
const IOS_NON_SAFARI_REGEX = /\b(CriOS|FxiOS|EdgiOS|OPiOS|DuckDuckGo)\b/i;

export function isInAppBrowserUserAgent(userAgent: string): boolean {
  return IN_APP_BROWSER_REGEX.test(userAgent);
}

export function isIosDevice(
  userAgent: string,
  maxTouchPoints: number = 0
): boolean {
  if (IOS_DEVICE_REGEX.test(userAgent)) {
    return true;
  }
  // iPadOS 13+ desktop-class UA reports Macintosh with multi-touch support
  return /\bMacintosh\b/.test(userAgent) && maxTouchPoints > 1;
}

export function detectInstallBannerMode(
  input: PlatformDetectionInput
): InstallBannerMode {
  if (input.isStandalone) {
    return "hidden";
  }

  const ua = input.userAgent || "";

  if (input.hasBeforeInstallPrompt) {
    return "chromium-prompt";
  }

  if (isInAppBrowserUserAgent(ua)) {
    return "in-app-browser";
  }

  if (isIosDevice(ua, input.maxTouchPoints ?? 0)) {
    if (IOS_NON_SAFARI_REGEX.test(ua)) {
      return "ios-other-browser";
    }
    if (/\bSafari\b/i.test(ua)) {
      return "ios-safari";
    }
    return "ios-other-browser";
  }

  return "hidden";
}

export function isDismissCooldownActive(
  dismissedAtRaw: string | null | undefined,
  nowMs: number = Date.now(),
  cooldownDays: number = DEFAULT_DISMISS_COOLDOWN_DAYS
): boolean {
  if (!dismissedAtRaw) {
    return false;
  }

  const timestamp = Number(dismissedAtRaw);
  if (!Number.isFinite(timestamp) || timestamp <= 0) {
    return false;
  }

  const cooldownMs = Math.max(0, cooldownDays) * 24 * 60 * 60 * 1000;
  return nowMs - timestamp < cooldownMs;
}

export function checkBrowserStandalone(): boolean {
  if (typeof window === "undefined") {
    return false;
  }

  const nav = window.navigator as Navigator & { standalone?: boolean };
  if (nav.standalone === true) {
    return true;
  }

  if (
    window.matchMedia?.("(display-mode: standalone)").matches ||
    window.matchMedia?.("(display-mode: fullscreen)").matches ||
    window.matchMedia?.("(display-mode: minimal-ui)").matches
  ) {
    return true;
  }

  if (
    typeof document !== "undefined" &&
    document.referrer.startsWith("android-app://")
  ) {
    return true;
  }

  return false;
}
