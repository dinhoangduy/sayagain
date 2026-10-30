"use client";

import type { ReactNode } from "react";
import { Eye, Mic } from "lucide-react";
import type { CardFramework } from "@/lib/episodes/schema";

export type SpeakingCardContent = {
  context: string;
  question: string;
  task: string;
  answer: string;
  level: string | null;
  image_url: string | null;
  framework: CardFramework | null;
};

interface SpeakingCardProps {
  card: SpeakingCardContent;
  revealed: boolean;
  onReveal: () => void;
  revealDisabled?: boolean;
  questionListenControl?: ReactNode;
  questionAudioError?: string | null;
  listenControl?: ReactNode;
  audioError?: string | null;
  grading?: ReactNode;
}

/**
 * Renders one speaking card: picture or situation, the question, and the
 * framework labels. After reveal, each step is shown as "Label: answer".
 * @param props.card - Situation, question, and optional framework steps.
 * @param props.revealed - Whether the sample answers are visible.
 * @param props.onReveal - Called when the learner asks to see the answers.
 * @param props.revealDisabled - Disables reveal while an earlier save is stuck.
 * @param props.questionListenControl - Listen button on the question label row.
 * @param props.questionAudioError - Playback error under the question.
 * @param props.listenControl - Optional listen button shown beside the sample answer.
 * @param props.audioError - Playback error under the sample answer.
 * @param props.grading - Rating controls shown only after reveal.
 * @returns The card surface.
 */
export function SpeakingCard({
  card,
  revealed,
  onReveal,
  revealDisabled = false,
  questionListenControl,
  questionAudioError,
  listenControl,
  audioError,
  grading,
}: SpeakingCardProps) {
  return (
    <article className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
      {card.image_url ? (
        <img
          src={card.image_url}
          alt={card.context}
          className="aspect-[4/3] w-full rounded-xl object-cover"
        />
      ) : (
        <div className="flex flex-wrap items-start justify-between gap-2">
          <p className="rounded-lg bg-[#eaf5ee] px-2.5 py-1.5 text-sm leading-snug font-semibold text-[#146c43]">
            {card.context}
          </p>
          {card.level ? (
            <span className="rounded-md bg-[#f2f6f3] px-2 py-0.5 text-xs font-bold text-[#52635a]">
              Level {card.level}
            </span>
          ) : null}
        </div>
      )}

      <div className="mt-5">
        <div className="flex min-h-9 items-center justify-between gap-3">
          <p className="text-xs font-semibold tracking-wide text-[#52635a] uppercase">
            Question
          </p>
          {questionListenControl ? (
            <div className="shrink-0">{questionListenControl}</div>
          ) : null}
        </div>
        <h1 className="mt-1.5 text-xl leading-snug font-bold text-[#132019] sm:text-2xl">
          “{card.question}”
        </h1>
        {questionAudioError ? (
          <p className="mt-1.5 text-xs text-[#9b2c2c]">{questionAudioError}</p>
        ) : null}
      </div>

      {card.framework ? (
        <div className="mt-5 rounded-xl border border-[#d6e8dc] bg-[#f4faf6] p-4">
          <div className="flex items-start gap-2.5">
            <Mic
              className="mt-0.5 h-4 w-4 shrink-0 text-[#146c43]"
              aria-hidden="true"
            />
            <div className="min-w-0 flex-1">
              <p className="text-xs font-semibold text-[#146c43]">
                Say your answer aloud
              </p>
              <p className="mt-1 text-sm font-semibold text-[#132019]">
                {card.framework.name}
              </p>
              <ol className="mt-3 space-y-1.5">
                {card.framework.steps.map((step, index) => (
                  <li
                    key={`${step.label}-${index}`}
                    className="flex items-center gap-2 text-sm font-medium text-[#132019]"
                  >
                    <span className="inline-flex h-5 w-5 shrink-0 items-center justify-center rounded-md bg-[#eaf5ee] text-[11px] font-bold text-[#146c43]">
                      {index + 1}
                    </span>
                    <span>{step.label}</span>
                  </li>
                ))}
              </ol>
            </div>
          </div>
        </div>
      ) : (
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
                {card.task}
              </p>
            </div>
          </div>
        </div>
      )}

      {!revealed ? (
        <div className="mt-6">
          <button
            type="button"
            onClick={onReveal}
            disabled={revealDisabled}
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
                Sample answer
              </p>
              {listenControl}
            </div>

            {card.framework ? (
              <ol className="mt-2 space-y-2.5">
                {card.framework.steps.map((step, index) => (
                  <li
                    key={`${step.label}-${index}`}
                    className="text-lg leading-relaxed font-semibold text-[#132019] sm:text-xl"
                  >
                    <span className="text-[#146c43]">{step.label}:</span>{" "}
                    {step.answer}
                  </li>
                ))}
              </ol>
            ) : (
              <p className="mt-2 text-lg leading-relaxed font-semibold text-[#132019] sm:text-xl">
                “{card.answer}”
              </p>
            )}

            {audioError ? (
              <p className="mt-1.5 text-xs text-[#9b2c2c]">{audioError}</p>
            ) : null}
          </div>

          {grading}
        </div>
      )}
    </article>
  );
}
