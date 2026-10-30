"use client";

import { useSyncExternalStore } from "react";
import { parseCardFramework } from "@/lib/episodes/schema";
import { createClient } from "@/lib/supabase/client";
import type { UserCardRow } from "@/lib/supabase/database.types";
import {
  applyLocalReview,
  pendingAfterUpload,
  syncDirection,
  type LocalCollection,
  type PendingReview,
  type StudyItem,
} from "@/lib/study/collection";

const STORAGE_PREFIX = "sayagain_collection_v1:";

export type StudyState = {
  ready: boolean;
  userId: string | null;
  items: StudyItem[];
  pendingCount: number;
  syncing: boolean;
  message: string | null;
};

const serverState: StudyState = {
  ready: false,
  userId: null,
  items: [],
  pendingCount: 0,
  syncing: false,
  message: null,
};

let state: StudyState = serverState;
let collection: LocalCollection | null = null;
const listeners = new Set<() => void>();
let bootStarted = false;
let syncLock: Promise<void> | null = null;

function emit(): void {
  state = {
    ready: state.ready,
    userId: collection?.userId ?? state.userId,
    items: collection?.items ?? [],
    pendingCount: collection?.pending.length ?? 0,
    syncing: state.syncing,
    message: state.message,
  };
  for (const listener of listeners) {
    listener();
  }
}

function storageKey(userId: string): string {
  return `${STORAGE_PREFIX}${userId}`;
}

function readCollection(userId: string): LocalCollection | null {
  try {
    const raw = window.localStorage.getItem(storageKey(userId));
    if (!raw) return null;
    const parsed = JSON.parse(raw) as LocalCollection;
    if (parsed?.userId !== userId || !Array.isArray(parsed.items)) {
      return null;
    }
    return {
      userId,
      savedAt: parsed.savedAt ?? new Date().toISOString(),
      items: parsed.items,
      pending: Array.isArray(parsed.pending) ? parsed.pending : [],
    };
  } catch {
    return null;
  }
}

function writeCollection(next: LocalCollection): void {
  collection = next;
  window.localStorage.setItem(storageKey(next.userId), JSON.stringify(next));
  emit();
}

function emptyCollection(userId: string): LocalCollection {
  return {
    userId,
    savedAt: new Date().toISOString(),
    items: [],
    pending: [],
  };
}

function asItems(value: unknown): StudyItem[] | null {
  if (!Array.isArray(value)) return null;
  const items: StudyItem[] = [];
  for (const row of value) {
    if (!row || typeof row !== "object") return null;
    const record = row as {
      userCard?: UserCardRow;
      card?: StudyItem["card"];
      episode?: StudyItem["episode"];
    };
    if (!record.userCard?.id || !record.card?.id || !record.episode?.id) {
      return null;
    }
    items.push({
      userCard: record.userCard,
      card: {
        ...record.card,
        framework: parseCardFramework(record.card.framework),
      },
      episode: record.episode,
    });
  }
  return items;
}

/**
 * Uploads pending reviews when this device has any, then stores the server snapshot.
 * A second call waits for the current one, then syncs again.
 * @returns Resolves when the local collection matches the server, or rejects on network failure.
 */
export function requestSync(): Promise<void> {
  return enqueueSync();
}

async function enqueueSync(): Promise<void> {
  if (syncLock) {
    await syncLock;
  }
  if (!collection && typeof window !== "undefined") {
    const supabase = createClient();
    const { data } = await supabase.auth.getSession();
    const userId = data.session?.user.id;
    if (!userId) return;
    collection = readCollection(userId) ?? emptyCollection(userId);
    state = { ...state, userId, ready: state.ready };
  }
  if (!collection) return;
  const run = runSync().finally(() => {
    syncLock = null;
  });
  syncLock = run;
  await run;
}

async function runSync(): Promise<void> {
  if (!collection) return;
  const direction = syncDirection(collection.pending.length);
  state = { ...state, syncing: true, message: null };
  emit();
  try {
    const supabase = createClient();
    const { data, error } = await supabase.rpc("sync_study_collection", {
      p_reviews: collection.pending.map((review) => review.rpcArgs),
    });
    if (error || !data || typeof data !== "object") {
      throw new Error(error?.message || "Sync could not reach the server.");
    }
    const payload = data as {
      uploaded?: { eventId: string; status: string }[];
      items?: unknown;
    };
    const items = asItems(payload.items);
    if (!items) {
      throw new Error("Sync returned an unreadable collection.");
    }
    const uploaded = Array.isArray(payload.uploaded) ? payload.uploaded : [];
    const pending = pendingAfterUpload(collection.pending, uploaded);
    const conflicts = uploaded.filter((item) => item.status === "version_conflict").length;
    writeCollection({
      userId: collection.userId,
      savedAt: new Date().toISOString(),
      items,
      pending,
    });
    const message =
      conflicts > 0
        ? "Synced. Another device already saved some cards, so those schedules were kept."
        : direction === "upload-then-download"
          ? "Synced. Reviews on this device were uploaded, then the latest schedule was downloaded."
          : "Synced. Downloaded the latest schedule.";
    state = { ...state, syncing: false, message };
    emit();
  } catch (error) {
    state = {
      ...state,
      syncing: false,
      message:
        error instanceof Error
          ? error.message
          : "Sync failed. Your reviews are still on this device.",
    };
    emit();
  }
}

/**
 * Saves one grade on this device. Nothing is sent until the learner presses Sync.
 * @param cardId - Graded card.
 * @param userCard - New schedule for that card.
 * @param review - Upload payload kept until Sync.
 * @returns void
 */
export function recordLocalReview(
  cardId: string,
  userCard: UserCardRow,
  review: PendingReview,
): void {
  if (!collection) return;
  writeCollection(
    applyLocalReview(
      collection,
      cardId,
      userCard,
      review,
      new Date().toISOString(),
    ),
  );
}

/**
 * Removes the on-device collection after study data is deleted on the server.
 * @param userId - Signed-in user whose local cache should disappear.
 * @returns void
 */
export function clearLocalStudy(userId: string): void {
  window.localStorage.removeItem(storageKey(userId));
  if (collection?.userId === userId) {
    collection = emptyCollection(userId);
    state = { ...state, message: null };
    emit();
  }
}

function subscribe(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function getState(): StudyState {
  return state;
}

/**
 * Reads the study collection. The server snapshot is empty so the first paint matches.
 * @returns The current on-device study state.
 */
export function useStudy(): StudyState {
  return useSyncExternalStore(subscribe, getState, () => serverState);
}

/**
 * Loads the signed-in collection from this device. The first visit downloads once.
 * Later visits do not call the server until Sync.
 * @returns void
 */
export function bootStudy(): void {
  if (bootStarted || typeof window === "undefined") return;
  bootStarted = true;
  void (async () => {
    const supabase = createClient();
    const { data } = await supabase.auth.getSession();
    const userId = data.session?.user.id ?? null;
    if (!userId) {
      collection = null;
      state = { ...serverState, ready: true };
      emit();
      return;
    }
    const stored = readCollection(userId);
    if (!stored) {
      collection = emptyCollection(userId);
      state = { ...state, ready: false, userId, syncing: true };
      emit();
      await requestSync();
      state = { ...state, ready: true, syncing: false };
      emit();
      return;
    }
    collection = stored;
    state = { ...state, ready: true, userId };
    emit();
  })();
}
