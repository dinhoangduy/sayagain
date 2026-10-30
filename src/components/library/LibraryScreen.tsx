"use client";

import Link from "next/link";
import { ArrowRight, BookOpen, Mic, Plus } from "lucide-react";
import { SAMPLE_EPISODE_ID } from "@/lib/episodes/sampleDeck";
import { summarizeDecks } from "@/lib/study/collection";
import { useStudy } from "@/lib/study/store";

/**
 * Library built from the on-device collection.
 * @returns Imported decks, or a prompt to import the sample deck.
 */
export function LibraryScreen() {
  const study = useStudy();
  if (!study.ready) {
    return (
      <div className="h-48 animate-pulse rounded-2xl border border-[#dce7e0] bg-white shadow-xs" />
    );
  }

  const collections = summarizeDecks(study.items, new Date().toISOString());

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-[#132019]">
            My Library
          </h1>
          <p className="mt-0.5 text-xs text-[#52635a] sm:text-sm">
            Imported episode decks and spaced-repetition progress.
          </p>
        </div>

        <Link
          href="/import"
          className="inline-flex min-h-[40px] shrink-0 items-center gap-1.5 rounded-xl bg-[#146c43] px-3.5 py-2 text-xs font-semibold text-white transition hover:bg-[#0f5635]"
        >
          <Plus className="h-4 w-4" aria-hidden="true" />
          <span>Import Deck</span>
        </Link>
      </div>

      {collections.length > 0 ? (
        <div className="space-y-3">
          {collections.map((col) => (
            <article
              key={col.id}
              className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs"
            >
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <span className="rounded-md bg-[#eaf5ee] px-2 py-0.5 font-mono text-xs font-semibold text-[#146c43]">
                    {col.language}
                  </span>
                </div>

                <span
                  className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                    col.due > 0
                      ? "bg-[#eaf5ee] text-[#146c43]"
                      : "bg-[#f2f6f3] text-[#52635a]"
                  }`}
                >
                  {col.due > 0 ? `${col.due} due now` : "Up to date"}
                </span>
              </div>

              <h2 className="mt-2.5 text-lg font-bold text-[#132019]">
                {col.title}
              </h2>
              {col.topic && (
                <p className="mt-0.5 text-xs text-[#52635a]">{col.topic}</p>
              )}

              <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-[#52635a]">
                <span>
                  <strong className="font-semibold text-[#132019]">
                    {col.total}
                  </strong>{" "}
                  {col.total === 1 ? "card" : "cards"} imported
                </span>
                <span>
                  <strong className="font-semibold text-[#132019]">
                    {col.reviewed}
                  </strong>{" "}
                  practiced at least once
                </span>
              </div>

              <div className="mt-4 flex flex-col gap-2 border-t border-[#edf2ef] pt-4 sm:flex-row">
                {col.due > 0 && (
                  <Link
                    href={`/review?episode=${encodeURIComponent(col.id)}`}
                    className="inline-flex min-h-[42px] flex-1 items-center justify-center gap-1.5 rounded-xl bg-[#146c43] px-4 py-2 text-xs font-semibold text-white hover:bg-[#0f5635] sm:text-sm"
                  >
                    <Mic className="h-4 w-4" aria-hidden="true" />
                    <span>Practice Due ({col.due})</span>
                  </Link>
                )}
                <Link
                  href={`/import/${col.id}`}
                  className="inline-flex min-h-[42px] flex-1 items-center justify-center gap-1.5 rounded-xl border border-[#dce7e0] bg-white px-4 py-2 text-xs font-semibold text-[#132019] hover:bg-[#f7faf8] sm:text-sm"
                >
                  <span>View Cards</span>
                  <ArrowRight className="h-3.5 w-3.5" aria-hidden="true" />
                </Link>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <div className="rounded-2xl border border-[#dce7e0] bg-white p-6 text-center shadow-xs sm:p-8">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#eaf5ee] text-[#146c43]">
            <BookOpen className="h-6 w-6" aria-hidden="true" />
          </div>
          <h2 className="mt-4 text-lg font-bold text-[#132019]">
            Your library is empty
          </h2>
          <p className="mx-auto mt-1.5 max-w-sm text-sm leading-relaxed text-[#52635a]">
            Import your first episode speaking deck to begin daily spaced-repetition practice.
          </p>
          <div className="mt-5">
            <Link
              href={`/import/${SAMPLE_EPISODE_ID}`}
              className="inline-flex min-h-[46px] items-center justify-center gap-2 rounded-xl bg-[#146c43] px-5 py-2.5 text-sm font-semibold text-white hover:bg-[#0f5635]"
            >
              <span>Preview SCN-021 You forgot their name again</span>
              <ArrowRight className="h-4 w-4" aria-hidden="true" />
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}
