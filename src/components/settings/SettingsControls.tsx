"use client";

import { useState, useSyncExternalStore } from "react";
import { useRouter } from "next/navigation";
import {
  Check,
  Download,
  Globe,
  Loader2,
  Smartphone,
  Trash2,
} from "lucide-react";
import {
  checkBrowserStandalone,
  INSTALL_DISMISS_STORAGE_KEY,
} from "@/lib/pwa/platform";
import { createClient } from "@/lib/supabase/client";
import { clearLocalStudy } from "@/lib/study/store";

const COMMON_TIMEZONES = [
  "UTC",
  "Asia/Ho_Chi_Minh",
  "Asia/Bangkok",
  "Asia/Singapore",
  "Asia/Tokyo",
  "Asia/Seoul",
  "Europe/London",
  "Europe/Berlin",
  "America/New_York",
  "America/Chicago",
  "America/Los_Angeles",
  "Australia/Sydney",
];

const emptySubscribe = () => () => {};

function getDetectedTimezone(): string {
  try {
    return Intl.DateTimeFormat().resolvedOptions().timeZone || "UTC";
  } catch {
    return "UTC";
  }
}

interface SettingsControlsProps {
  userId: string;
  userEmail: string;
  initialTimezone: string;
}

export function SettingsControls({
  userId,
  userEmail,
  initialTimezone,
}: SettingsControlsProps) {
  const router = useRouter();
  const isStandalone = useSyncExternalStore(
    emptySubscribe,
    () => checkBrowserStandalone(),
    () => false
  );
  const deviceTimezone = useSyncExternalStore(
    emptySubscribe,
    getDetectedTimezone,
    () => "UTC"
  );

  const [timezone, setTimezone] = useState(initialTimezone);
  const [savingTz, setSavingTz] = useState(false);
  const [tzSaved, setTzSaved] = useState(false);
  const [tzError, setTzError] = useState<string | null>(null);

  const [bannerResetDone, setBannerResetDone] = useState(false);

  const [exporting, setExporting] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [dataMessage, setDataMessage] = useState<string | null>(null);

  const timezoneOptions = Array.from(
    new Set([timezone, deviceTimezone, ...COMMON_TIMEZONES].filter(Boolean))
  );

  const handleSaveTimezone = async (nextTimezone: string) => {
    setTimezone(nextTimezone);
    setSavingTz(true);
    setTzSaved(false);
    setTzError(null);

    try {
      const supabase = createClient();
      const { error } = await supabase.from("user_settings").upsert(
        {
          user_id: userId,
          timezone: nextTimezone,
        },
        { onConflict: "user_id" }
      );

      if (error) {
        throw new Error(error.message);
      }

      setTzSaved(true);
      window.setTimeout(() => setTzSaved(false), 2500);
      router.refresh();
    } catch (err) {
      setTzError(
        err instanceof Error ? err.message : "Could not save time zone."
      );
    } finally {
      setSavingTz(false);
    }
  };

  const handleResetInstallBanner = () => {
    if (typeof window === "undefined") return;
    window.localStorage.removeItem(INSTALL_DISMISS_STORAGE_KEY);
    window.dispatchEvent(new Event("sayagain:reset-install-banner"));
    setBannerResetDone(true);
    window.setTimeout(() => setBannerResetDone(false), 2500);
  };

  const handleExportData = async () => {
    if (exporting) return;
    setExporting(true);
    setDataMessage(null);

    try {
      const supabase = createClient();
      const [cardsRes, eventsRes, importsRes, settingsRes] = await Promise.all([
        supabase.from("user_cards").select("*").order("created_at"),
        supabase
          .from("review_events")
          .select("*")
          .order("reviewed_at", { ascending: false }),
        supabase.from("user_episode_imports").select("*").order("imported_at"),
        supabase.from("user_settings").select("*").maybeSingle(),
      ]);

      const payload = {
        exportedAt: new Date().toISOString(),
        account: {
          userId,
          email: userEmail,
        },
        settings: settingsRes.data ?? { timezone },
        episodeImports: importsRes.data ?? [],
        userCards: cardsRes.data ?? [],
        reviewEvents: eventsRes.data ?? [],
      };

      const blob = new Blob([JSON.stringify(payload, null, 2)], {
        type: "application/json",
      });
      const downloadUrl = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = downloadUrl;
      anchor.download = `sayagain-study-data-${new Date()
        .toISOString()
        .slice(0, 10)}.json`;
      document.body.appendChild(anchor);
      anchor.click();
      anchor.remove();
      URL.revokeObjectURL(downloadUrl);

      setDataMessage("Downloaded your SayAgain study data export.");
    } catch {
      setDataMessage("Could not export study data. Please try again.");
    } finally {
      setExporting(false);
    }
  };

  const handleDeleteStudyData = async () => {
    if (deleting) return;
    setDeleting(true);
    setDataMessage(null);

    try {
      const supabase = createClient();
      const results = await Promise.all([
        supabase.from("review_events").delete().eq("user_id", userId),
        supabase.from("user_cards").delete().eq("user_id", userId),
        supabase.from("user_episode_imports").delete().eq("user_id", userId),
        supabase.from("user_settings").delete().eq("user_id", userId),
      ]);

      const firstError = results.find((r) => r.error)?.error;
      if (firstError) {
        throw new Error(firstError.message);
      }

      setConfirmDelete(false);
      clearLocalStudy(userId);
      setDataMessage("All imported cards and review history have been deleted.");
      router.refresh();
    } catch (err) {
      setDataMessage(
        err instanceof Error
          ? err.message
          : "Could not delete study data. Please retry."
      );
    } finally {
      setDeleting(false);
    }
  };

  return (
    <div className="space-y-5">
      {/* Time Zone Card */}
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <div className="flex items-start gap-2.5">
          <Globe
            className="mt-0.5 h-5 w-5 shrink-0 text-[#146c43]"
            aria-hidden="true"
          />
          <div className="min-w-0 flex-1">
            <h2 className="text-base font-bold text-[#132019]">Time Zone</h2>
            <p className="mt-0.5 text-xs leading-relaxed text-[#52635a]">
              Used to display daily schedules consistently across devices.
            </p>

            <div className="mt-3.5 flex flex-col gap-2.5 sm:flex-row sm:items-center">
              <label htmlFor="timezone-select" className="sr-only">
                Time zone
              </label>
              <select
                id="timezone-select"
                value={timezone}
                disabled={savingTz}
                onChange={(e) => void handleSaveTimezone(e.target.value)}
                className="min-h-[44px] flex-1 rounded-xl border border-[#cddcd3] bg-white px-3 py-2 text-sm text-[#132019] focus:border-[#146c43] focus:outline-none"
              >
                {timezoneOptions.map((tz) => (
                  <option key={tz} value={tz}>
                    {tz}
                  </option>
                ))}
              </select>

              {deviceTimezone && deviceTimezone !== timezone && (
                <button
                  type="button"
                  disabled={savingTz}
                  onClick={() => void handleSaveTimezone(deviceTimezone)}
                  className="inline-flex min-h-[44px] shrink-0 cursor-pointer items-center justify-center rounded-xl border border-[#c8e3d2] bg-[#f4faf6] px-3.5 py-2 text-xs font-semibold text-[#146c43] hover:bg-[#eaf5ee]"
                >
                  Use device ({deviceTimezone})
                </button>
              )}
            </div>

            {savingTz && (
              <p className="mt-2 inline-flex items-center gap-1.5 text-xs text-[#52635a]">
                <Loader2 className="h-3.5 w-3.5 animate-spin" />
                <span>Saving…</span>
              </p>
            )}
            {tzSaved && (
              <p className="mt-2 inline-flex items-center gap-1 text-xs font-semibold text-[#146c43]">
                <Check className="h-3.5 w-3.5" />
                <span>Time zone saved</span>
              </p>
            )}
            {tzError && (
              <p className="mt-2 text-xs text-[#9b2c2c]">{tzError}</p>
            )}
          </div>
        </div>
      </section>

      {/* Install App Guidance */}
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <div className="flex items-start gap-2.5">
          <Smartphone
            className="mt-0.5 h-5 w-5 shrink-0 text-[#146c43]"
            aria-hidden="true"
          />
          <div className="min-w-0 flex-1 space-y-3">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <h2 className="text-base font-bold text-[#132019]">
                Install SayAgain App
              </h2>
              <span
                className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                  isStandalone
                    ? "bg-[#eaf5ee] text-[#146c43]"
                    : "bg-[#f2f6f3] text-[#52635a]"
                }`}
              >
                {isStandalone ? "Installed mode" : "Browser mode"}
              </span>
            </div>

            {isStandalone ? (
              <p className="text-xs leading-relaxed text-[#355443]">
                You’re already running SayAgain from your home screen in
                standalone Web App mode.
              </p>
            ) : (
              <>
                <ul className="space-y-1.5 text-xs leading-relaxed text-[#52635a]">
                  <li>
                    <strong className="text-[#132019]">
                      Android / Desktop Chrome:
                    </strong>{" "}
                    Tap <em>Install</em> in the top banner or use the browser
                    menu → <em>Install app</em>.
                  </li>
                  <li>
                    <strong className="text-[#132019]">
                      iPhone / iPad Safari:
                    </strong>{" "}
                    Tap <em>Share</em> in Safari’s toolbar →{" "}
                    <em>Add to Home Screen</em>.
                  </li>
                  <li>
                    <strong className="text-[#132019]">
                      TikTok / Instagram / Facebook:
                    </strong>{" "}
                    Tap <em>⋯</em> → <em>Open in Browser</em> first.
                  </li>
                </ul>

                <button
                  type="button"
                  onClick={handleResetInstallBanner}
                  className="inline-flex min-h-[38px] cursor-pointer items-center gap-1.5 rounded-xl border border-[#c8e3d2] bg-[#f4faf6] px-3.5 py-1.5 text-xs font-semibold text-[#146c43] hover:bg-[#eaf5ee]"
                >
                  {bannerResetDone ? (
                    <>
                      <Check className="h-3.5 w-3.5" />
                      <span>Install banner re-enabled</span>
                    </>
                  ) : (
                    <span>Show top install banner again</span>
                  )}
                </button>
              </>
            )}
          </div>
        </div>
      </section>

      {/* Privacy, Data Export & Deletion */}
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <h2 className="text-base font-bold text-[#132019]">
          Privacy & Study Data
        </h2>
        <p className="mt-1.5 text-xs leading-relaxed text-[#52635a]">
          SayAgain never records, stores, or uploads microphone audio. Only your
          Google sign-in email, imported card IDs, and FSRS review timestamps
          are saved in your private Row-Level-Secured database rows.
        </p>

        {dataMessage && (
          <p
            role="status"
            className="mt-3 rounded-xl bg-[#f4faf6] px-3.5 py-2.5 text-xs font-medium text-[#146c43]"
          >
            {dataMessage}
          </p>
        )}

        <div className="mt-4 flex flex-col gap-2.5 sm:flex-row">
          <button
            type="button"
            onClick={() => void handleExportData()}
            disabled={exporting}
            className="inline-flex min-h-[42px] cursor-pointer items-center justify-center gap-1.5 rounded-xl border border-[#dce7e0] bg-white px-4 py-2 text-xs font-semibold text-[#132019] hover:bg-[#f7faf8] disabled:opacity-60"
          >
            {exporting ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <Download className="h-3.5 w-3.5" />
            )}
            <span>Export My Study Data (JSON)</span>
          </button>

          {!confirmDelete ? (
            <button
              type="button"
              onClick={() => setConfirmDelete(true)}
              className="inline-flex min-h-[42px] cursor-pointer items-center justify-center gap-1.5 rounded-xl border border-[#f2c6c6] bg-[#fff5f5] px-4 py-2 text-xs font-semibold text-[#9b2c2c] hover:bg-[#ffebeb]"
            >
              <Trash2 className="h-3.5 w-3.5" />
              <span>Delete My Study Progress</span>
            </button>
          ) : (
            <div className="flex flex-wrap items-center gap-2 rounded-xl border border-[#f2c6c6] bg-[#fff5f5] px-3 py-2">
              <span className="text-xs font-semibold text-[#9b2c2c]">
                Permanently erase all cards & reviews?
              </span>
              <button
                type="button"
                disabled={deleting}
                onClick={() => void handleDeleteStudyData()}
                className="rounded-lg bg-[#9b2c2c] px-2.5 py-1 text-xs font-semibold text-white hover:bg-[#7f2323]"
              >
                {deleting ? "Deleting…" : "Confirm"}
              </button>
              <button
                type="button"
                disabled={deleting}
                onClick={() => setConfirmDelete(false)}
                className="rounded-lg border border-[#dce7e0] bg-white px-2.5 py-1 text-xs font-semibold text-[#52635a]"
              >
                Cancel
              </button>
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
