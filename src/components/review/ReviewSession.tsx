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
import {
  CheckCircle2,
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
import { recordLocalReview } from "@/lib/study/store";
import type { CardFollowUp, CardFramework } from "@/lib/episodes/schema";
import { SpeakingCard } from "@/components/review/SpeakingCard";
import type { UserCardRow } from "@/lib/supabase/database.types";

export interface DueReviewItem {
  userCard: UserCardRow;
  card: {
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
    followUps?: CardFollowUp[];
  };
  episode: {
    id: string;
    title: string;
    language: string;
  };
}

const GRADE_BUTTON_STYLES: Record<ReviewGradeLabel, string> = {
  Again:
    "border-[#f2c6c6] bg-[#fff5f5] text-[#9b2c2c] hover:bg-[#ffebeb] focus-visible:ring-[#9b2c2c]",
  Hard: "border-[#f3d999] bg-[#fffbeb] text-[#8c5808] hover:bg-[#fef3c7] focus-visible:ring-[#8c5808]",
  Good: "border-[#a6e0be] bg-[#ecfdf3] text-[#146c43] hover:bg-[#dcfce7] focus-visible:ring-[#146c43]",
  Easy: "border-[#b2ddff] bg-[#eff8ff] text-[#175cd3] hover:bg-[#dbeafe] focus-visible:ring-[#175cd3]",
};

type AudioTarget = "question" | "answer";

interface AudioPlaybackError {
  target: AudioTarget;
  message: string;
}

function isIgnorableSpeechError(error: string): boolean {
  return error === "canceled" || error === "interrupted";
}

/**
 * Speaks on the next turn so a cancel in the current click does not drop the line.
 * @param utterance - Prepared speech line.
 * @param stillCurrent - Returns false when a newer click has replaced this playback.
 * @returns void
 */
function speakOnNextTurn(
  utterance: SpeechSynthesisUtterance,
  stillCurrent: () => boolean,
): void {
  window.setTimeout(() => {
    if (!stillCurrent()) {
      return;
    }
    window.speechSynthesis.speak(utterance);
  }, 40);
}

/**
 * Toggles spoken playback for one line on the card.
 * @param props.playing - Whether this line is the one currently speaking.
 * @param props.name - Spoken name used in the accessible label.
 * @param props.onClick - Starts or stops playback for this line.
 * @returns A listen or stop button.
 */
function PlaybackButton({
  playing,
  name,
  onClick,
}: {
  playing: boolean;
  name: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={playing ? `Stop ${name}` : `Listen to ${name}`}
      className="inline-flex h-9 w-[5.75rem] shrink-0 cursor-pointer items-center justify-center gap-1.5 rounded-xl border border-[#c8e3d2] bg-[#f4faf6] px-3 text-xs font-semibold text-[#146c43] transition hover:bg-[#eaf5ee]"
    >
      {playing ? (
        <>
          <Square className="h-3.5 w-3.5 fill-current" aria-hidden="true" />
          <span>Stop</span>
        </>
      ) : (
        <>
          <Volume2 className="h-3.5 w-3.5" aria-hidden="true" />
          <span>Listen</span>
        </>
      )}
    </button>
  );
}

function spokenAnswer(card: DueReviewItem["card"]): string {
  if (card.framework) {
    return card.framework.steps.map((step) => step.answer).join(" ");
  }
  return card.answer;
}

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
  const isOnline = useSyncExternalStore(
    subscribeOnlineStatus,
    () => window.navigator.onLine,
    () => true
  );

  const [queue] = useState<DueReviewItem[]>(initialQueue);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const [ratingPreviews, setRatingPreviews] = useState<RatingPreviewOption[]>(
    []
  );
  const [sessionCounts, setSessionCounts] = useState<
    Record<ReviewGradeLabel, number>
  >({
    Again: 0,
    Hard: 0,
    Good: 0,
    Easy: 0,
  });

  const audioRef = useRef<HTMLAudioElement | null>(null);
  const playbackToken = useRef(0);
  const [playingTarget, setPlayingTarget] = useState<AudioTarget | null>(null);
  const [audioError, setAudioError] = useState<AudioPlaybackError | null>(
    null
  );

  const currentItem = queue[currentIndex] ?? null;
  const isFinished = currentIndex >= queue.length;

  const stopAnyAudio = useCallback(() => {
    playbackToken.current += 1;
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
      audioRef.current = null;
    }
    if (typeof window !== "undefined" && "speechSynthesis" in window) {
      window.speechSynthesis.cancel();
    }
    setPlayingTarget(null);
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

  const handleGrade = useCallback(
    async (grade: ReviewGrade) => {
      if (!currentItem || !revealed) {
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
      const nowIso = now.toISOString();
      const eventId = crypto.randomUUID();

      recordLocalReview(
        currentItem.card.id,
        {
          ...currentItem.userCard,
          due_at: transition.dueAtIso,
          last_review_at: nowIso,
          fsrs_state: transition.fsrsState,
          stability: transition.stability,
          difficulty: transition.difficulty,
          elapsed_days: transition.elapsedDays,
          scheduled_days: transition.scheduledDays,
          learning_steps: transition.learningSteps,
          reps: transition.reps,
          lapses: transition.lapses,
          version: currentItem.userCard.version + 1,
          updated_at: nowIso,
        },
        {
          eventId,
          cardId: currentItem.card.id,
          question: currentItem.card.question,
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
        },
      );

      setSessionCounts((prev) => ({
        ...prev,
        [gradeLabel]: prev[gradeLabel] + 1,
      }));
      setRevealed(false);
      setCurrentIndex(currentIndex + 1);
    },
    [currentIndex, currentItem, revealed, stopAnyAudio],
  );

  const speakText = (text: string, target: AudioTarget, rate: number) => {
    if (!currentItem || !("speechSynthesis" in window)) {
      return;
    }
    const token = playbackToken.current;
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = currentItem.episode.language || "en-US";
    utterance.rate = rate;
    utterance.onend = () => {
      if (playbackToken.current === token) {
        setPlayingTarget(null);
      }
    };
    utterance.onerror = (event) => {
      if (playbackToken.current !== token) {
        return;
      }
      setPlayingTarget(null);
      if (!isIgnorableSpeechError(event.error)) {
        setAudioError({
          target,
          message: "Could not play the voice in this browser.",
        });
      }
    };
    setPlayingTarget(target);
    window.speechSynthesis.getVoices();
    speakOnNextTurn(utterance, () => playbackToken.current === token);
  };

  const handlePlay = (target: AudioTarget) => {
    if (!currentItem) return;
    setAudioError(null);

    if (playingTarget === target) {
      stopAnyAudio();
      return;
    }

    stopAnyAudio();

    if (target === "question") {
      speakText(currentItem.card.question, "question", 0.9);
      return;
    }

    if (currentItem.card.audio_url) {
      const token = playbackToken.current;
      const audio = new Audio(currentItem.card.audio_url);
      audioRef.current = audio;
      setPlayingTarget("answer");
      audio.onended = () => {
        if (playbackToken.current !== token) return;
        setPlayingTarget(null);
        audioRef.current = null;
      };
      audio.onerror = () => {
        if (playbackToken.current !== token) return;
        setPlayingTarget(null);
        audioRef.current = null;
        setAudioError({
          target: "answer",
          message: "Could not load recorded audio file.",
        });
      };
      audio.play().catch(() => {
        if (playbackToken.current !== token) return;
        setPlayingTarget(null);
        audioRef.current = null;
        setAudioError({
          target: "answer",
          message: "Audio playback was blocked by the browser.",
        });
      });
      return;
    }

    speakText(spokenAnswer(currentItem.card), "answer", 0.96);
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

      if (!currentItem) return;

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
  }, [currentItem, handleGrade, revealed]);

  const totalReviewed = useMemo(
    () =>
      sessionCounts.Again +
      sessionCounts.Hard +
      sessionCounts.Good +
      sessionCounts.Easy,
    [sessionCounts]
  );

  // Empty due queue state
  if (queue.length === 0) {
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
            You’re offline. Grades stay on this device until you press Sync.
          </span>
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
            {`Reviewed ${totalReviewed} ${
              totalReviewed === 1 ? "card" : "cards"
            } on this device. Press Sync to update your account.`}
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
                <span className="truncate font-medium text-[#146c43]">
                  {currentItem.episode.title}
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

            <SpeakingCard
              card={currentItem.card}
              revealed={revealed}
              onReveal={() => setRevealed(true)}
              questionAudioError={
                audioError?.target === "question" ? audioError.message : null
              }
              questionListenControl={
                <PlaybackButton
                  playing={playingTarget === "question"}
                  name="the question"
                  onClick={() => handlePlay("question")}
                />
              }
              audioError={
                audioError?.target === "answer" ? audioError.message : null
              }
              listenControl={
                <PlaybackButton
                  playing={playingTarget === "answer"}
                  name="the sample answer"
                  onClick={() => handlePlay("answer")}
                />
              }
              grading={
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
              }
            />
          </>
        )
      )}
    </div>
  );
}
