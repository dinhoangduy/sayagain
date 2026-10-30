import type { CardFramework } from "@/lib/episodes/schema";
import type { UserCardRow } from "@/lib/supabase/database.types";
import type { ReviewGradeLabel } from "@/lib/fsrs/scheduler";

export type StudyCard = {
  id: string;
  episode_id: string;
  level: string | null;
  context: string;
  question: string;
  task: string;
  answer: string;
  audio_url: string | null;
  image_url: string | null;
  framework: CardFramework | null;
};

export type StudyEpisode = {
  id: string;
  title: string;
  topic: string;
  language: string;
};

export type StudyItem = {
  userCard: UserCardRow;
  card: StudyCard;
  episode: StudyEpisode;
};

export type PendingReviewArgs = {
  p_event_id: string;
  p_card_id: string;
  p_expected_version: number;
  p_rating: number;
  p_fsrs_state: number;
  p_due_offset_ms: number;
  p_stability: number;
  p_difficulty: number;
  p_elapsed_days: number;
  p_scheduled_days: number;
  p_learning_steps: number;
  p_reps: number;
  p_lapses: number;
};

export type PendingReview = {
  eventId: string;
  cardId: string;
  question: string;
  gradeLabel: ReviewGradeLabel;
  rpcArgs: PendingReviewArgs;
};

export type LocalCollection = {
  userId: string;
  savedAt: string;
  items: StudyItem[];
  pending: PendingReview[];
};

export type DeckSummary = {
  id: string;
  title: string;
  topic: string;
  language: string;
  total: number;
  due: number;
  reviewed: number;
};

export type SyncDirection = "upload-then-download" | "download";

/**
 * Anki's Sync button is one two-way pass. Local reviews upload first so a
 * download cannot replace them, then the server snapshot is saved locally.
 * With nothing waiting, the same press only downloads.
 * @param pendingCount - Reviews stored on this device and not yet uploaded.
 * @returns The direction for this press.
 */
export function syncDirection(pendingCount: number): SyncDirection {
  return pendingCount > 0 ? "upload-then-download" : "download";
}

/**
 * Keeps a graded card on the device and queues it for the next Sync.
 * @param collection - Current local collection for this user.
 * @param cardId - Card that was graded.
 * @param userCard - Schedule after the grade, including the incremented version.
 * @param review - Payload to upload later.
 * @param savedAt - ISO time stored with the collection.
 * @returns Next collection. Unknown cards are left unchanged.
 */
export function applyLocalReview(
  collection: LocalCollection,
  cardId: string,
  userCard: UserCardRow,
  review: PendingReview,
  savedAt: string,
): LocalCollection {
  const items = collection.items.map((item) =>
    item.card.id === cardId ? { ...item, userCard } : item,
  );
  return {
    ...collection,
    savedAt,
    items,
    pending: [...collection.pending, review],
  };
}

/**
 * Groups the local collection the way Home and Library display it.
 * @param items - Cards stored on this device.
 * @param nowIso - Current time. A card is due when `due_at` is at or before this.
 * @returns One summary per episode, due cards first.
 */
export function summarizeDecks(items: StudyItem[], nowIso: string): DeckSummary[] {
  const byEpisode = new Map<string, DeckSummary>();
  for (const item of items) {
    const current = byEpisode.get(item.episode.id) ?? {
      id: item.episode.id,
      title: item.episode.title,
      topic: item.episode.topic,
      language: item.episode.language,
      total: 0,
      due: 0,
      reviewed: 0,
    };
    current.total += 1;
    if (item.userCard.due_at <= nowIso) {
      current.due += 1;
    }
    if (item.userCard.reps > 0) {
      current.reviewed += 1;
    }
    byEpisode.set(item.episode.id, current);
  }
  return Array.from(byEpisode.values()).sort((a, b) => b.due - a.due);
}

/**
 * Drops uploaded reviews and keeps only ones the server could not apply.
 * @param pending - Reviews that were sent.
 * @param uploaded - Per-review status from `sync_study_collection`.
 * @returns Reviews that must stay on the device for another Sync.
 */
export function pendingAfterUpload(
  pending: PendingReview[],
  uploaded: { eventId: string; status: string }[],
): PendingReview[] {
  const failed = new Set(
    uploaded.filter((item) => item.status === "error").map((item) => item.eventId),
  );
  if (uploaded.length === 0) {
    return pending;
  }
  return pending.filter((review) => failed.has(review.eventId));
}
