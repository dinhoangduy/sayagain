import { describe, expect, it } from "vitest";
import type { UserCardRow } from "@/lib/supabase/database.types";
import {
  applyLocalReview,
  pendingAfterUpload,
  syncDirection,
  type LocalCollection,
  type PendingReview,
} from "@/lib/study/collection";

function review(eventId: string): PendingReview {
  return {
    eventId,
    cardId: "card-1",
    question: "Can you finish this by tomorrow?",
    gradeLabel: "Good",
    rpcArgs: {
      p_event_id: eventId,
      p_card_id: "card-1",
      p_expected_version: 1,
      p_rating: 3,
      p_fsrs_state: 1,
      p_due_offset_ms: 600000,
      p_stability: 1,
      p_difficulty: 5,
      p_elapsed_days: 0,
      p_scheduled_days: 0,
      p_learning_steps: 1,
      p_reps: 1,
      p_lapses: 0,
    },
  };
}

const userCard = {
  id: "uc-1",
  user_id: "user-1",
  card_id: "card-1",
  due_at: "2026-10-30T12:10:00.000Z",
  last_review_at: "2026-10-30T12:00:00.000Z",
  fsrs_state: 1,
  stability: 1,
  difficulty: 5,
  elapsed_days: 0,
  scheduled_days: 0,
  learning_steps: 1,
  reps: 1,
  lapses: 0,
  version: 2,
  created_at: "2026-10-30T12:00:00.000Z",
  updated_at: "2026-10-30T12:00:00.000Z",
} as UserCardRow;

const collection: LocalCollection = {
  userId: "user-1",
  savedAt: "2026-10-30T12:00:00.000Z",
  pending: [],
  items: [
    {
      userCard: { ...userCard, version: 1, reps: 0 },
      card: {
        id: "card-1",
        episode_id: "ep-1",
        level: null,
        context: "A deadline",
        question: "Can you finish this by tomorrow?",
        task: "Capacity",
        answer: "I can start today.",
        audio_url: null,
        image_url: null,
        framework: null,
        followUps: [],
      },
      episode: {
        id: "ep-1",
        title: "Deadline",
        topic: "Work",
        language: "en-US",
      },
    },
  ],
};

describe("study sync", () => {
  it("uploads before downloading when this device has reviews", () => {
    expect(syncDirection(2)).toBe("upload-then-download");
    expect(syncDirection(0)).toBe("download");
  });

  it("keeps a grade on the device until sync", () => {
    const next = applyLocalReview(
      collection,
      "card-1",
      userCard,
      review("event-1"),
      "2026-10-30T12:00:01.000Z",
    );
    expect(next.pending).toHaveLength(1);
    expect(next.items[0]?.userCard.version).toBe(2);
  });

  it("drops applied reviews and keeps failed ones", () => {
    const pending = [review("ok-1"), review("bad-1")];
    const left = pendingAfterUpload(pending, [
      { eventId: "ok-1", status: "ok" },
      { eventId: "bad-1", status: "error" },
    ]);
    expect(left.map((item) => item.eventId)).toEqual(["bad-1"]);
  });
});
