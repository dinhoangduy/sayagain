"use client";

import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
  useSyncExternalStore,
} from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  AlertTriangle,
  CheckCircle2,
  Eye,
  Loader2,
  Mic,
  RefreshCw,
  Square,
  Volume2,
  WifiOff,
} from "lucide-react";
import {
  computeReviewTransition,
  previewCardRatings,
  REVIEW_GRADES,
  type RatingPreviewOption,
  type ReviewGrade,
  type ReviewGradeLabel,
} from "@/lib/fsrs/scheduler";
import { createClient } from "@/lib/supabase/client";
import type {
  SubmitCardReviewResult,
  UserCardRow,
} from "@/lib/supabase/database.types";

export interface DueReviewItem {
  userCard: UserCardRow;
  card: {
    id: string;
    episode_id: string;
    level: string;
    context: string;
    question: string;
    task: string;
    answer: string;
    audio_url: string | null;
  };
  episode: {
    id: string;
    title: string;
    language: string;
  };
}

interface PendingReviewRecord {
  eventId: string;
  cardId: string;
  cardPrompt: string;
  gradeLabel: ReviewGradeLabel;
  rpcArgs: {
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
}

interface FailedSaveState {
  record: PendingReviewRecord;
  errorMessage: string;
}

const PENDING_STORAGE_KEY = "sayagain_unsaved_review_v1";

const GRADE_BUTTON_STYLES: Record<ReviewGradeLabel, string> = {
  Again:
    "border-[#f2c6c6] bg-[#fff5f5] text-[#9b2c2c] hover:bg-[#ffebeb] focus-visible:ring-[#9b2c2c]",
  Hard: "border-[#f3d999] bg-[#fffbeb] text-[#8c5808] hover:bg-[#fef3c7] focus-visible:ring-[#8c5808]",
  Good: "border-[#a6e0be] bg-[#ecfdf3] text-[#146c43] hover:bg-[#dcfce7] focus-visible:ring-[#146c43]",
  Easy: "border-[#b2ddff] bg-[#eff8ff] text-[#175cd3] hover:bg-[#dbeafe] focus-visible:ring-[#175cd3]",
};

const emptySubscribe = () => () => {};

function subscribeOnlineStatus(onStoreChange: () => void): () => void {
  if (typeof window === "undefined") {
    return () => {};
  }
  window.addEventListener("online", onStoreChange);
  window.addEventListener("offline", onStoreChange);
  return () => {
    window.removeEventListener("online", onStoreChange);
    window.removeEventListener("offline", onStoreChange);
  };
}

function readStoredFailedSave(): FailedSaveState | null {
  if (typeof window === "undefined") {
    return null;
  }
  try {
    const savedRaw = window.sessionStorage.getItem(PENDING_STORAGE_KEY);
    if (!savedRaw) return null;
    const parsed = JSON.parse(savedRaw) as PendingReviewRecord;
    if (parsed?.eventId && parsed?.rpcArgs) {
      return {
        record: parsed,
        errorMessage:
          "An earlier graded review was not saved before reload. Tap Retry Save to sync it.",
      };
    }
  } catch {
    // Ignore malformed storage entry
  }
  return null;
}

interface ReviewSessionProps {
  initialQueue: DueReviewItem[];
  filteredEpisodeId?: string | null;
  totalDueAllEpisodes: number;
}

export function ReviewSession({
  initialQueue,
  filteredEpisodeId = null,
  totalDueAllEpisodes,
}: ReviewSessionProps) {
  const router = useRouter();
  const isClient = useSyncExternalStore(
    emptySubscribe,
    () => true,
    () => false
  );
  const isOnline = useSyncExternalStore(
    subscribeOnlineStatus,
    () => window.navigator.onLine,
    () => true
  );
  const hasSpeechSynthesis = useSyncExternalStore(
    emptySubscribe,
    () => "speechSynthesis" in window,
    () => false
  );

  const [queue] = useState<DueReviewItem[]>(initialQueue);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const [ratingPreviews, setRatingPreviews] = useState<RatingPreviewOption[]>(
    []
  );
  const [savingCount, setSavingCount] = useState(0);
  const [runtimeFailedSave, setRuntimeFailedSave] =
    useState<FailedSaveState | null>(null);
  const [clearedStoredSave, setClearedStoredSave] = useState(false);
  const [conflictNotice, setConflictNotice] = useState<string | null>(null);
  const [sessionCounts, setSessionCounts] = useState<
    Record<ReviewGradeLabel, number>
  >({
    Again: 0,
    Hard: 0,
    Good: 0,
    Easy: 0,
  });

  // Audio playback state
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [isPlayingAudio, setIsPlayingAudio] = useState(false);
  const [audioError, setAudioError] = useState<string | null>(null);

  const failedSave: FailedSaveState | null =
    runtimeFailedSave ??
    (isClient && !clearedStoredSave ? readStoredFailedSave() : null);

  const currentItem = queue[currentIndex] ?? null;
  const isFinished = currentIndex >= queue.length;

  const stopAnyAudio = useCallback(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
      audioRef.current = null;
    }
    if (typeof window !== "undefined" && "speechSynthesis" in window) {
      window.speechSynthesis.cancel();
    }
    setIsPlayingAudio(false);
  }, []);

  useEffect(() => {
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
      if (typeof window !== "undefined" && "speechSynthesis" in window) {
        window.speechSynthesis.cancel();
      }
    };
  }, []);

  // Compute live client-side ts-fsrs interval previews whenever current card changes
  useEffect(() => {
    let cancelled = false;

    if (!currentItem) {
      return;
    }

    previewCardRatings(currentItem.userCard, new Date())
      .then((options) => {
        if (!cancelled) {
          setRatingPreviews(options);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setRatingPreviews([]);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [currentItem]);

  const persistReviewRecord = useCallback(
    async (record: PendingReviewRecord) => {
      setSavingCount((c) => c + 1);
      try {
        const supabase = createClient();
        const { data, error } = await supabase.rpc(
          "submit_card_review",
          record.rpcArgs
        );

        if (error || !data) {
          throw new Error(
            error?.message || "Could not save review. Check your connection."
          );
        }

        const result = data as unknown as SubmitCardReviewResult;

        if (typeof window !== "undefined") {
          window.sessionStorage.removeItem(PENDING_STORAGE_KEY);
        }
        setClearedStoredSave(true);
        setRuntimeFailedSave(null);

        if (result.status === "version_conflict") {
          setConflictNotice(
            `Card "${record.cardPrompt}" was already reviewed on another device (v${
              result.current_version ?? result.user_card.version
            }). Kept your latest saved schedule without overwriting.`
          );
        }

        return true;
      } catch (err) {
        if (typeof window !== "undefined") {
          try {
            window.sessionStorage.setItem(
              PENDING_STORAGE_KEY,
              JSON.stringify(record)
            );
          } catch {
            // Storage quota exceeded; in-memory retry still active
          }
        }
        setRuntimeFailedSave({
          record,
          errorMessage:
            err instanceof Error
              ? err.message
              : "Network failure while saving review.",
        });
        return false;
      } finally {
        setSavingCount((c) => Math.max(0, c - 1));
      }
    },
    []
  );

  const handleGrade = useCallback(
    async (grade: ReviewGrade) => {
      if (!currentItem || !revealed || failedSave) {
        return;
      }

      stopAnyAudio();
      setAudioError(null);
      setRatingPreviews([]);

      const gradeMeta = REVIEW_GRADES.find((g) => g.grade === grade);
      const gradeLabel: ReviewGradeLabel = gradeMeta?.label ?? "Good";

      const now = new Date();
      const transition = await computeReviewTransition(
        currentItem.userCard,
        grade,
        now
      );

      const eventId = crypto.randomUUID();
      const record: PendingReviewRecord = {
        eventId,
        cardId: currentItem.card.id,
        cardPrompt: currentItem.card.question,
        gradeLabel,
        rpcArgs: {
          p_event_id: eventId,
          p_card_id: currentItem.card.id,
          p_expected_version: currentItem.userCard.version,
          p_rating: transition.grade,
          p_fsrs_state: transition.fsrsState,
          p_due_offset_ms: transition.dueOffsetMs,
          p_stability: transition.stability,
          p_difficulty: transition.difficulty,
          p_elapsed_days: transition.elapsedDays,
          p_scheduled_days: transition.scheduledDays,
          p_learning_steps: transition.learningSteps,
          p_reps: transition.reps,
          p_lapses: transition.lapses,
        },
      };

      if (typeof window !== "undefined") {
        try {
          window.sessionStorage.setItem(
            PENDING_STORAGE_KEY,
            JSON.stringify(record)
          );
        } catch {
          // Ignore storage error
        }
      }

      const nextIndex = currentIndex + 1;
      setSessionCounts((prev) => ({
        ...prev,
        [gradeLabel]: prev[gradeLabel] + 1,
      }));
      setRevealed(false);
      setCurrentIndex(nextIndex);

      const ok = await persistReviewRecord(record);
      if (ok && nextIndex >= queue.length) {
        router.refresh();
      }
    },
    [
      currentIndex,
      currentItem,
      failedSave,
      persistReviewRecord,
      queue.length,
      revealed,
      router,
      stopAnyAudio,
    ]
  );

  const handleRetryFailedSave = async () => {
    if (!failedSave) return;
    const ok = await persistReviewRecord(failedSave.record);
    if (ok && isFinished) {
      router.refresh();
    }
  };

  const handlePlayAudio = () => {
    if (!currentItem) return;
    setAudioError(null);

    if (isPlayingAudio) {
      stopAnyAudio();
      return;
    }

    if (currentItem.card.audio_url) {
      const audio = new Audio(currentItem.card.audio_url);
      audioRef.current = audio;
      setIsPlayingAudio(true);

      audio.onended = () => {
        setIsPlayingAudio(false);
        audioRef.current = null;
      };
      audio.onerror = () => {
        setIsPlayingAudio(false);
        audioRef.current = null;
        setAudioError("Could not load recorded audio file.");
      };
      audio.play().catch(() => {
        setIsPlayingAudio(false);
        audioRef.current = null;
        setAudioError("Audio playback was blocked by the browser.");
      });
      return;
    }

    if (typeof window !== "undefined" && "speechSynthesis" in window) {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(currentItem.card.answer);
      utterance.lang = currentItem.episode.language || "en-US";
      utterance.rate = 0.96;
      utterance.onend = () => setIsPlayingAudio(false);
      utterance.onerror = () => setIsPlayingAudio(false);
      setIsPlayingAudio(true);
      window.speechSynthesis.speak(utterance);
    }
  };

  // Keyboard shortcuts for desktop study (Space/Enter to reveal, 1-4 to grade)
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (
        event.target instanceof HTMLInputElement ||
        event.target instanceof HTMLTextAreaElement
      ) {
        return;
      }

      if (!currentItem || failedSave) return;

      if (!revealed && (event.key === " " || event.key === "Enter")) {
        if (
          document.activeElement?.tagName === "BUTTON" ||
          document.activeElement?.tagName === "A"
        ) {
          return;
        }
        event.preventDefault();
        setRevealed(true);
        return;
      }

      if (revealed) {
        const keyMap: Record<string, ReviewGrade> = {
          "1": 1,
          "2": 2,
          "3": 3,
          "4": 4,
        };
        const mapped = keyMap[event.key];
        if (mapped) {
          event.preventDefault();
          void handleGrade(mapped);
        }
      }
    };

    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [currentItem, failedSave, handleGrade, revealed]);

  const totalReviewed = useMemo(
    () =>
      sessionCounts.Again +
      sessionCounts.Hard +
      sessionCounts.Good +
      sessionCounts.Easy,
    [sessionCounts]
  );

  // Empty due queue state
  if (queue.length === 0 && !failedSave) {
    return (
      <div className="rounded-2xl border border-[#dce7e0] bg-white p-6 text-center shadow-xs sm:p-8">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#eaf5ee] text-[#146c43]">
          <CheckCircle2 className="h-6 w-6" aria-hidden="true" />
        </div>
        <h1 className="mt-4 text-xl font-bold tracking-tight text-[#132019]">
          {filteredEpisodeId
            ? "No cards due in this episode right now"
            : "You’re all caught up for now"}
        </h1>
        <p className="mx-auto mt-1.5 max-w-sm text-sm leading-relaxed text-[#52635a]">
          {filteredEpisodeId && totalDueAllEpisodes > 0
            ? `You still have ${totalDueAllEpisodes} due ${
                totalDueAllEpisodes === 1 ? "card" : "cards"
              } across your other imported episodes.`
            : "Your next spaced-repetition cards will appear here automatically when they become due."}
        </p>

        <div className="mt-6 flex flex-col justify-center gap-2.5 sm:flex-row">
          {filteredEpisodeId && totalDueAllEpisodes > 0 ? (
            <Link
              href="/review"
              className="inline-flex min-h-[46px] items-center justify-center rounded-xl bg-[#146c43] px-5 py-2.5 text-sm font-semibold text-white hover:bg-[#0f5635]"
            >
              Review All Due Cards ({totalDueAllEpisodes})
            </Link>
          ) : (
            <Link
              href="/import"
              className="inline-flex min-h-[46px] items-center justify-center rounded-xl bg-[#146c43] px-5 py-2.5 text-sm font-semibold text-white hover:bg-[#0f5635]"
            >
              Import an Episode Deck
            </Link>
          )}
          <Link
            href="/"
            className="inline-flex min-h-[46px] items-center justify-center rounded-xl border border-[#dce7e0] bg-white px-5 py-2.5 text-sm font-semibold text-[#132019] hover:bg-[#f7faf8]"
          >
            Back to Home
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {!isOnline && (
        <div
          role="status"
          className="flex items-center gap-2 rounded-xl border border-[#f3d999] bg-[#fffbeb] px-3.5 py-2.5 text-xs font-medium text-[#8c5808]"
        >
          <WifiOff className="h-4 w-4 shrink-0" aria-hidden="true" />
          <span>
            You’re offline. Reconnect before grading so your review progress is
            saved.
          </span>
        </div>
      )}

      {failedSave && (
        <div
          role="alert"
          className="rounded-2xl border border-[#f2c6c6] bg-[#fff5f5] p-4 text-xs text-[#9b2c2c]"
        >
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex items-start gap-2.5">
              <AlertTriangle
                className="mt-0.5 h-4 w-4 shrink-0"
                aria-hidden="true"
              />
              <div className="space-y-0.5">
                <p className="font-semibold">
                  Review save failed ({failedSave.record.gradeLabel})
                </p>
                <p className="leading-relaxed text-[#7f2323]">
                  {failedSave.errorMessage}
                </p>
              </div>
            </div>

            <button
              type="button"
              onClick={() => void handleRetryFailedSave()}
              disabled={savingCount > 0}
              className="inline-flex min-h-[40px] shrink-0 cursor-pointer items-center justify-center gap-1.5 rounded-xl bg-[#9b2c2c] px-4 py-2 text-xs font-semibold text-white hover:bg-[#7f2323] disabled:opacity-60"
            >
              {savingCount > 0 ? (
                <>
                  <Loader2 className="h-3.5 w-3.5 animate-spin" />
                  <span>Saving…</span>
                </>
              ) : (
                <>
                  <RefreshCw className="h-3.5 w-3.5" />
                  <span>Retry Save</span>
                </>
              )}
            </button>
          </div>
        </div>
      )}

      {conflictNotice && (
        <div
          role="status"
          className="flex items-start justify-between gap-3 rounded-xl border border-[#b2ddff] bg-[#eff8ff] px-3.5 py-2.5 text-xs text-[#175cd3]"
        >
          <p className="leading-relaxed">{conflictNotice}</p>
          <button
            type="button"
            onClick={() => setConflictNotice(null)}
            className="shrink-0 font-semibold underline"
          >
            Dismiss
          </button>
        </div>
      )}

      {/* Session Completed View */}
      {isFinished ? (
        <div className="rounded-2xl border border-[#dce7e0] bg-white p-6 text-center shadow-xs sm:p-7">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#eaf5ee] text-[#146c43]">
            <CheckCircle2 className="h-6 w-6" aria-hidden="true" />
          </div>
          <h1 className="mt-4 text-2xl font-bold tracking-tight text-[#132019]">
            Session complete
          </h1>
          <p className="mt-1 text-sm text-[#52635a]">
            {savingCount > 0
              ? "Finishing sync to your account…"
              : failedSave
              ? "Retry the unsaved card above to finish syncing."
              : `Reviewed ${totalReviewed} ${
                  totalReviewed === 1 ? "card" : "cards"
                } and synced your FSRS schedule.`}
          </p>

          <div className="mt-5 grid grid-cols-4 gap-2">
            {(["Again", "Hard", "Good", "Easy"] as const).map((label) => (
              <div
                key={label}
                className="rounded-xl border border-[#edf2ef] bg-[#f7faf8] px-2 py-2.5"
              >
                <p className="text-lg font-bold text-[#132019]">
                  {sessionCounts[label]}
                </p>
                <p className="text-[11px] font-medium text-[#52635a]">
                  {label}
                </p>
              </div>
            ))}
          </div>

          <div className="mt-6 flex flex-col justify-center gap-2.5 sm:flex-row">
            <Link
              href="/"
              className="inline-flex min-h-[46px] items-center justify-center rounded-xl bg-[#146c43] px-5 py-2.5 text-sm font-semibold text-white hover:bg-[#0f5635]"
            >
              Back to Home
            </Link>
            {sessionCounts.Again > 0 && (
              <button
                type="button"
                onClick={() => window.location.reload()}
                className="inline-flex min-h-[46px] cursor-pointer items-center justify-center rounded-xl border border-[#dce7e0] bg-white px-5 py-2.5 text-sm font-semibold text-[#132019] hover:bg-[#f7faf8]"
              >
                Check Short-Interval Cards
              </button>
            )}
          </div>
        </div>
      ) : (
        currentItem && (
          <>
            {/* Progress & Status Header */}
            <div className="space-y-2">
              <div className="flex items-center justify-between text-xs font-medium text-[#52635a]">
                <span>
                  Card{" "}
                  <strong className="font-semibold text-[#132019]">
                    {currentIndex + 1}
                  </strong>{" "}
                  of {queue.length}
                </span>
                <span className="inline-flex items-center gap-1.5">
                  {savingCount > 0 && (
                    <span className="inline-flex items-center gap-1 text-[#146c43]">
                      <Loader2 className="h-3 w-3 animate-spin" />
                      <span>Saving</span>
                    </span>
                  )}
                  <span className="truncate font-medium text-[#146c43]">
                    {currentItem.episode.title}
                  </span>
                </span>
              </div>
              <div
                aria-hidden="true"
                className="h-1.5 w-full overflow-hidden rounded-full bg-[#e4eee8]"
              >
                <div
                  className="h-full rounded-full bg-[#146c43] transition-all duration-200"
                  style={{
                    width: `${Math.min(
                      100,
                      Math.round(((currentIndex + 1) / queue.length) * 100)
                    )}%`,
                  }}
                />
              </div>
            </div>

            {/* Flashcard Surface */}
            <article className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <span className="inline-flex items-center rounded-lg bg-[#eaf5ee] px-2.5 py-1 text-xs font-semibold text-[#146c43]">
                  {currentItem.card.context}
                </span>
                <span className="rounded-md bg-[#f2f6f3] px-2 py-0.5 text-xs font-bold text-[#52635a]">
                  Level {currentItem.card.level}
                </span>
              </div>

              {/* Step 1: Question / Prompt */}
              <div className="mt-5">
                <p className="text-xs font-semibold tracking-wide text-[#52635a] uppercase">
                  Prompt
                </p>
                <h1 className="mt-1.5 text-xl leading-snug font-bold text-[#132019] sm:text-2xl">
                  “{currentItem.card.question}”
                </h1>
              </div>

              {/* Step 2: Speaking Task */}
              <div className="mt-5 rounded-xl border border-[#d6e8dc] bg-[#f4faf6] p-4">
                <div className="flex items-start gap-2.5">
                  <Mic
                    className="mt-0.5 h-4 w-4 shrink-0 text-[#146c43]"
                    aria-hidden="true"
                  />
                  <div>
                    <p className="text-xs font-semibold text-[#146c43]">
                      Say your answer aloud
                    </p>
                    <p className="mt-0.5 text-sm leading-relaxed font-medium text-[#132019]">
                      {currentItem.card.task}
                    </p>
                  </div>
                </div>
              </div>

              {/* Step 3: Reveal CTA or Model Answer + Audio + Grading */}
              {!revealed ? (
                <div className="mt-6">
                  <button
                    type="button"
                    onClick={() => setRevealed(true)}
                    disabled={Boolean(failedSave)}
                    className="inline-flex min-h-[52px] w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#146c43] px-5 py-3 text-base font-semibold text-white transition hover:bg-[#0f5635] disabled:opacity-50"
                  >
                    <Eye className="h-4 w-4" aria-hidden="true" />
                    <span>Reveal Answer</span>
                  </button>
                </div>
              ) : (
                <div className="mt-6 space-y-5 border-t border-[#edf2ef] pt-5">
                  <div>
                    <div className="flex items-center justify-between gap-2">
                      <p className="text-xs font-semibold tracking-wide text-[#146c43] uppercase">
                        Model Response
                      </p>

                      {(currentItem.card.audio_url || hasSpeechSynthesis) && (
                        <button
                          type="button"
                          onClick={handlePlayAudio}
                          className="inline-flex min-h-[36px] cursor-pointer items-center gap-1.5 rounded-xl border border-[#c8e3d2] bg-[#f4faf6] px-3 py-1.5 text-xs font-semibold text-[#146c43] transition hover:bg-[#eaf5ee]"
                        >
                          {isPlayingAudio ? (
                            <>
                              <Square
                                className="h-3.5 w-3.5 fill-current"
                                aria-hidden="true"
                              />
                              <span>Stop</span>
                            </>
                          ) : (
                            <>
                              <Volume2
                                className="h-3.5 w-3.5"
                                aria-hidden="true"
                              />
                              <span>
                                {currentItem.card.audio_url
                                  ? "Listen"
                                  : "Listen (Voice)"}
                              </span>
                            </>
                          )}
                        </button>
                      )}
                    </div>

                    <p className="mt-2 text-lg leading-relaxed font-semibold text-[#132019] sm:text-xl">
                      “{currentItem.card.answer}”
                    </p>

                    {audioError && (
                      <p className="mt-1.5 text-xs text-[#9b2c2c]">
                        {audioError}
                      </p>
                    )}
                  </div>

                  {/* Step 4: FSRS Rating Buttons */}
                  <div className="space-y-2">
                    <p className="text-center text-xs font-medium text-[#52635a]">
                      How natural did your spoken answer feel?
                    </p>
                    <div className="grid grid-cols-4 gap-2">
                      {REVIEW_GRADES.map(({ grade, label }) => {
                        const preview = ratingPreviews.find(
                          (p) => p.grade === grade
                        );
                        return (
                          <button
                            key={label}
                            type="button"
                            onClick={() => void handleGrade(grade)}
                            disabled={Boolean(failedSave)}
                            className={`flex min-h-[58px] cursor-pointer flex-col items-center justify-center rounded-xl border px-1.5 py-2 transition focus:outline-none focus-visible:ring-2 disabled:opacity-50 ${GRADE_BUTTON_STYLES[label]}`}
                          >
                            <span className="text-xs font-bold sm:text-sm">
                              {label}
                            </span>
                            <span className="mt-0.5 text-[11px] font-medium opacity-85">
                              {preview?.intervalLabel ?? "…"}
                            </span>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                </div>
              )}
            </article>
          </>
        )
      )}
    </div>
  );
}
