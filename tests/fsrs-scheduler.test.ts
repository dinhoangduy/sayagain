import { describe, expect, it } from "vitest";
import { Rating, State } from "ts-fsrs";
import {
  computeReviewTransition,
  formatIntervalDelta,
  previewCardRatings,
} from "@/lib/fsrs/scheduler";

const BASE_USER_CARD = {
  card_id: "episode-001-a2-order",
  due_at: "2026-10-30T09:00:00.000Z",
  last_review_at: null,
  fsrs_state: 0,
  stability: 0,
  difficulty: 0,
  scheduled_days: 0,
  learning_steps: 0,
  reps: 0,
  lapses: 0,
};

describe("ts-fsrs client scheduling", () => {
  it("previews monotonic non-decreasing intervals across Again/Hard/Good/Easy", async () => {
    const now = new Date("2026-10-30T09:00:00.000Z");
    const previews = await previewCardRatings(BASE_USER_CARD, now);

    expect(previews.map((p) => p.label)).toEqual([
      "Again",
      "Hard",
      "Good",
      "Easy",
    ]);
    expect(previews[0].dueOffsetMs).toBeGreaterThan(0);
    expect(previews[2].dueOffsetMs).toBeGreaterThanOrEqual(
      previews[0].dueOffsetMs
    );
    expect(previews[3].dueOffsetMs).toBeGreaterThan(previews[2].dueOffsetMs);
  });

  it("advances a card through learning into review and tracks lapses on Again", async () => {
    const t0 = new Date("2026-10-30T09:00:00.000Z");

    // First review: Easy graduates directly to Review state
    const first = await computeReviewTransition(
      BASE_USER_CARD,
      Rating.Easy,
      t0
    );
    expect(first.reps).toBe(1);
    expect(first.lapses).toBe(0);
    expect(first.stability).toBeGreaterThan(0);
    expect(first.difficulty).toBeGreaterThan(0);
    expect(first.fsrsState).toBe(State.Review);
    expect(first.scheduledDays).toBeGreaterThanOrEqual(1);

    // Second review after scheduled interval with Again -> Relearning + lapse
    const t1 = new Date(t0.getTime() + first.dueOffsetMs);
    const second = await computeReviewTransition(
      {
        card_id: BASE_USER_CARD.card_id,
        due_at: first.dueAtIso,
        last_review_at: t0.toISOString(),
        fsrs_state: first.fsrsState,
        stability: first.stability,
        difficulty: first.difficulty,
        scheduled_days: first.scheduledDays,
        learning_steps: first.learningSteps,
        reps: first.reps,
        lapses: first.lapses,
      },
      Rating.Again,
      t1
    );

    expect(second.reps).toBe(2);
    expect(second.lapses).toBe(1);
    expect(second.fsrsState).toBe(State.Relearning);
    expect(second.elapsedDays).toBeGreaterThanOrEqual(1);
  });

  it("formats interval deltas cleanly for mobile buttons", () => {
    expect(formatIntervalDelta(60_000)).toBe("1m");
    expect(formatIntervalDelta(600_000)).toBe("10m");
    expect(formatIntervalDelta(3 * 86_400_000)).toBe("3d");
  });
});
