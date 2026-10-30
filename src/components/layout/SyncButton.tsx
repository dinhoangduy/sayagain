"use client";

import { useEffect } from "react";
import { RefreshCw } from "lucide-react";
import { bootStudy, requestSync, useStudy } from "@/lib/study/store";

/**
 * Starts the on-device study cache once per page load.
 * @returns Nothing.
 */
export function StudyBoot() {
  useEffect(() => {
    bootStudy();
  }, []);
  return null;
}

/**
 * One Anki-style sync. Pending reviews upload first, then the latest schedule downloads.
 * @returns The header sync control, hidden for signed-out visitors.
 */
export function SyncButton() {
  const study = useStudy();
  if (!study.userId) return null;

  const label =
    study.pendingCount > 0
      ? `Sync ${study.pendingCount}`
      : "Sync";

  return (
    <button
      type="button"
      onClick={() => void requestSync()}
      disabled={study.syncing}
      title={
        study.pendingCount > 0
          ? "Upload reviews saved on this device, then download the latest schedule"
          : "Download the latest schedule"
      }
      aria-label={label}
      className="inline-flex min-h-[38px] cursor-pointer items-center gap-1 rounded-xl border border-[#dce7e0] bg-white px-2.5 py-1.5 text-xs font-semibold text-[#132019] transition hover:bg-[#f7faf8] disabled:opacity-60"
    >
      <RefreshCw
        className={`h-3.5 w-3.5 shrink-0 ${study.syncing ? "animate-spin" : ""}`}
        aria-hidden="true"
      />
      <span className="hidden sm:inline">{label}</span>
      {study.pendingCount > 0 ? (
        <span className="inline-flex min-w-4 items-center justify-center rounded-full bg-[#146c43] px-1 text-[10px] font-bold text-white sm:hidden">
          {study.pendingCount}
        </span>
      ) : null}
    </button>
  );
}

/**
 * Shows the result of the last sync under the header.
 * @returns A status line, or nothing when there is no message.
 */
export function SyncStatus() {
  const study = useStudy();
  if (!study.userId || !study.message) return null;
  return (
    <p className="mb-3 text-xs leading-relaxed text-[#52635a]">{study.message}</p>
  );
}
