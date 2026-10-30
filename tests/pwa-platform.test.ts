import { describe, expect, it } from "vitest";
import {
  detectInstallBannerMode,
  isDismissCooldownActive,
} from "@/lib/pwa/platform";

describe("PWA install banner platform detection & cooldown", () => {
  it("always hides banner when already running in standalone/installed mode", () => {
    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 Chrome/131.0.0.0 Mobile Safari/537.36",
        isStandalone: true,
        hasBeforeInstallPrompt: true,
      })
    ).toBe("hidden");

    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 Version/18.1 Mobile/15E148 Safari/604.1",
        isStandalone: true,
        hasBeforeInstallPrompt: false,
      })
    ).toBe("hidden");
  });

  it("uses native Chromium prompt mode when beforeinstallprompt has fired", () => {
    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 Chrome/131.0.0.0 Mobile Safari/537.36",
        isStandalone: false,
        hasBeforeInstallPrompt: true,
      })
    ).toBe("chromium-prompt");
  });

  it("detects iOS & iPadOS Safari for manual Share -> Add to Home Screen steps", () => {
    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1",
        isStandalone: false,
        hasBeforeInstallPrompt: false,
      })
    ).toBe("ios-safari");

    // iPadOS desktop-class UA
    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15",
        isStandalone: false,
        hasBeforeInstallPrompt: false,
        maxTouchPoints: 5,
      })
    ).toBe("ios-safari");
  });

  it("distinguishes iOS non-Safari browsers and social in-app browsers", () => {
    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 CriOS/131.0.0.0 Mobile/15E148 Safari/604.1",
        isStandalone: false,
        hasBeforeInstallPrompt: false,
      })
    ).toBe("ios-other-browser");

    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 musical_ly_35.1.0 TikTok",
        isStandalone: false,
        hasBeforeInstallPrompt: false,
      })
    ).toBe("in-app-browser");

    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/131.0.0.0 Mobile Safari/537.36 Instagram 350.0.0.0",
        isStandalone: false,
        hasBeforeInstallPrompt: false,
      })
    ).toBe("in-app-browser");
  });

  it("hides banner on desktop browsers without beforeinstallprompt", () => {
    expect(
      detectInstallBannerMode({
        userAgent:
          "Mozilla/5.0 (X11; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0",
        isStandalone: false,
        hasBeforeInstallPrompt: false,
      })
    ).toBe("hidden");
  });

  it("respects 7-day dismissal cooldown accurately", () => {
    const t0 = 1_700_000_000_000;
    expect(isDismissCooldownActive(null, t0, 7)).toBe(false);
    expect(
      isDismissCooldownActive(String(t0), t0 + 3 * 24 * 60 * 60 * 1000, 7)
    ).toBe(true);
    expect(
      isDismissCooldownActive(String(t0), t0 + 8 * 24 * 60 * 60 * 1000, 7)
    ).toBe(false);
  });
});
