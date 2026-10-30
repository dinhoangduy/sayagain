import {
  DefaultScheduler,
  Rating,
  State,
  type DefaultScheduler as DefaultSchedulerInstance,
  type DefaultSchedulerCardInput,
  type ScheduleStatus,
} from "ts-fsrs";
import type { UserCardRow } from "@/lib/supabase/database.types";

export type ReviewGrade =
  | typeof Rating.Again
  | typeof Rating.Hard
  | typeof Rating.Good
  | typeof Rating.Easy;

export type ReviewGradeLabel = "Again" | "Hard" | "Good" | "Easy";

export interface RatingPreviewOption {
  grade: ReviewGrade;
  label: ReviewGradeLabel;
  intervalLabel: string;
  dueOffsetMs: number;
  nextState: number;
}

export interface ReviewTransitionPayload {
  grade: ReviewGrade;
  fsrsState: number;
  dueAtIso: string;
  dueOffsetMs: number;
  stability: number;
  difficulty: number;
  elapsedDays: number;
  scheduledDays: number;
  learningSteps: number;
  reps: number;
  lapses: number;
}

export const REVIEW_GRADES: ReadonlyArray<{
  grade: ReviewGrade;
  label: ReviewGradeLabel;
}> = [
  { grade: Rating.Again, label: "Again" },
  { grade: Rating.Hard, label: "Hard" },
  { grade: Rating.Good, label: "Good" },
  { grade: Rating.Easy, label: "Easy" },
];

let schedulerPromise: Promise<DefaultSchedulerInstance<"FSRS-6">> | null = null;

export function getFsrsScheduler(): Promise<
  DefaultSchedulerInstance<"FSRS-6">
> {
  if (!schedulerPromise) {
    schedulerPromise = DefaultScheduler({
      version: "FSRS-6",
      desiredRetention: 0.9,
      enableShortTerm: true,
      learningSteps: ["1m", "10m"],
      relearningSteps: ["10m"],
      enableFuzz: false,
      maximumInterval: 36_500,
    });
  }
  return schedulerPromise;
}

function normalizeFsrsState(raw: number): State {
  if (
    raw === State.New ||
    raw === State.Learning ||
    raw === State.Review ||
    raw === State.Relearning
  ) {
    return raw;
  }
  return State.New;
}

function stateToScheduleStatus(state: State): ScheduleStatus {
  switch (state) {
    case State.New:
      return "new";
    case State.Learning:
    case State.Relearning:
      return "learning";
    case State.Review:
      return "review";
  }
}

export function userCardToFsrsInput(
  row: Pick<
    UserCardRow,
    | "card_id"
    | "due_at"
    | "last_review_at"
    | "fsrs_state"
    | "stability"
    | "difficulty"
    | "scheduled_days"
    | "learning_steps"
    | "reps"
    | "lapses"
  >,
  fallbackNow: Date = new Date()
): DefaultSchedulerCardInput<"FSRS-6"> {
  const parsedDue = new Date(row.due_at);
  const dueAt = Number.isNaN(parsedDue.getTime()) ? fallbackNow : parsedDue;

  let lastReviewAt: Date | null = null;
  if (row.last_review_at) {
    const parsedLast = new Date(row.last_review_at);
    if (!Number.isNaN(parsedLast.getTime())) {
      lastReviewAt = parsedLast;
    }
  }

  const normalizedState = normalizeFsrsState(row.fsrs_state);

  return {
    cardId: row.card_id,
    state: normalizedState,
    scheduleStatus: stateToScheduleStatus(normalizedState),
    stability: Math.max(0, Number(row.stability) || 0),
    difficulty: Math.max(0, Number(row.difficulty) || 0),
    dueAt,
    lastReviewAt,
    reps: Math.max(0, Math.trunc(row.reps || 0)),
    lapses: Math.max(0, Math.trunc(row.lapses || 0)),
    scheduledDays: Math.max(0, Math.trunc(row.scheduled_days || 0)),
    learningStep: Math.max(0, Math.trunc(row.learning_steps || 0)),
  };
}

export function formatIntervalDelta(deltaMs: number): string {
  const clampedMs = Math.max(0, deltaMs);
  const minutes = Math.round(clampedMs / 60_000);

  if (minutes < 1) {
    return "<1m";
  }
  if (minutes < 60) {
    return `${minutes}m`;
  }

  const hours = Math.round(clampedMs / 3_600_000);
  if (hours < 24) {
    return `${hours}h`;
  }

  const days = clampedMs / 86_400_000;
  if (days < 30) {
    const roundedDays = Math.round(days);
    return `${Math.max(1, roundedDays)}d`;
  }

  if (days < 365) {
    const months = Math.round((days / 30) * 10) / 10;
    return `${months}mo`;
  }

  const years = Math.round((days / 365) * 10) / 10;
  return `${years}y`;
}

export async function previewCardRatings(
  row: Pick<
    UserCardRow,
    | "card_id"
    | "due_at"
    | "last_review_at"
    | "fsrs_state"
    | "stability"
    | "difficulty"
    | "scheduled_days"
    | "learning_steps"
    | "reps"
    | "lapses"
  >,
  now: Date = new Date()
): Promise<RatingPreviewOption[]> {
  const scheduler = await getFsrsScheduler();
  const card = userCardToFsrsInput(row, now);
  const preview = scheduler.preview({ card, now });

  const byGrade = new Map<ReviewGrade, RatingPreviewOption>();
  for (const item of preview) {
    const grade = item.grade as ReviewGrade;
    const labelEntry = REVIEW_GRADES.find((g) => g.grade === grade);
    if (!labelEntry) continue;

    const dueOffsetMs = Math.max(0, item.card.dueAt.getTime() - now.getTime());
    byGrade.set(grade, {
      grade,
      label: labelEntry.label,
      intervalLabel: formatIntervalDelta(dueOffsetMs),
      dueOffsetMs,
      nextState: item.card.state,
    });
  }

  return REVIEW_GRADES.map((entry) => {
    const computed = byGrade.get(entry.grade);
    if (computed) return computed;
    return {
      grade: entry.grade,
      label: entry.label,
      intervalLabel: "1m",
      dueOffsetMs: 60_000,
      nextState: State.Learning,
    };
  });
}

export async function computeReviewTransition(
  row: Pick<
    UserCardRow,
    | "card_id"
    | "due_at"
    | "last_review_at"
    | "fsrs_state"
    | "stability"
    | "difficulty"
    | "scheduled_days"
    | "learning_steps"
    | "reps"
    | "lapses"
  >,
  grade: ReviewGrade,
  now: Date = new Date()
): Promise<ReviewTransitionPayload> {
  const scheduler = await getFsrsScheduler();
  const cardInput = userCardToFsrsInput(row, now);
  const { card: nextCard } = scheduler.review({
    card: cardInput,
    grade,
    now,
  });

  const dueOffsetMs = Math.max(0, nextCard.dueAt.getTime() - now.getTime());
  const elapsedDays = cardInput.lastReviewAt
    ? Math.max(
        0,
        Math.floor(scheduler.chrono.difference(cardInput.lastReviewAt, now))
      )
    : 0;

  return {
    grade,
    fsrsState: nextCard.state,
    dueAtIso: nextCard.dueAt.toISOString(),
    dueOffsetMs,
    stability: nextCard.stability,
    difficulty: nextCard.difficulty,
    elapsedDays,
    scheduledDays: Math.max(0, Math.round(nextCard.scheduledDays)),
    learningSteps: Math.max(0, Math.trunc(nextCard.learningStep)),
    reps: Math.max(0, Math.trunc(nextCard.reps)),
    lapses: Math.max(0, Math.trunc(nextCard.lapses)),
  };
}

export function describeFsrsState(state: number): string {
  switch (state) {
    case State.New:
      return "New";
    case State.Learning:
      return "Learning";
    case State.Review:
      return "Review";
    case State.Relearning:
      return "Relearning";
    default:
      return "New";
  }
}
