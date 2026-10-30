import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  CheckCircle2,
  Clock,
  Mic,
  Sparkles,
} from "lucide-react";
import { EpisodeLookupForm } from "@/components/import/EpisodeLookupForm";
import { createClient } from "@/lib/supabase/server";

function formatRelativeUpcoming(dueIso: string, nowMs: number): string {
  const diffMs = Math.max(0, new Date(dueIso).getTime() - nowMs);
  const mins = Math.ceil(diffMs / 60_000);
  if (mins < 60) {
    return `in ${Math.max(1, mins)} min`;
  }
  const hours = Math.round(diffMs / 3_600_000);
  if (hours < 24) {
    return `in ${hours} ${hours === 1 ? "hour" : "hours"}`;
  }
  const days = Math.round(diffMs / 86_400_000);
  return `in ${days} ${days === 1 ? "day" : "days"}`;
}

export default async function HomePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return (
      <div className="space-y-6 py-2">
        <section className="rounded-2xl border border-[#dce7e0] bg-white p-6 shadow-xs sm:p-7">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-[#eaf5ee] px-3 py-1 text-xs font-semibold text-[#146c43]">
            <Sparkles className="h-3.5 w-3.5" aria-hidden="true" />
            <span>English Speaking Practice</span>
          </span>

          <h1 className="mt-3.5 text-2xl leading-tight font-bold tracking-tight text-[#132019] sm:text-3xl">
            Turn video episodes into daily speaking reflexes.
          </h1>
          <p className="mt-2.5 text-sm leading-relaxed text-[#52635a] sm:text-base">
            Import flashcard prompts from English Speaking Challenge episodes,
            answer out loud, and review right before you forget with FSRS spaced
            repetition.
          </p>

          <div className="mt-6 flex flex-col gap-2.5 sm:flex-row">
            <Link
              href="/login"
              className="inline-flex min-h-[48px] flex-1 items-center justify-center gap-2 rounded-xl bg-[#146c43] px-5 py-3 text-sm font-semibold text-white transition hover:bg-[#0f5635]"
            >
              <span>Sign in with Google</span>
              <ArrowRight className="h-4 w-4" aria-hidden="true" />
            </Link>
            <Link
              href="/import/episode-001"
              className="inline-flex min-h-[48px] flex-1 items-center justify-center gap-2 rounded-xl border border-[#c8e3d2] bg-[#f4faf6] px-5 py-3 text-sm font-semibold text-[#146c43] transition hover:bg-[#eaf5ee]"
            >
              <span>Try Episode 001</span>
            </Link>
          </div>
        </section>

        <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 sm:p-6">
          <h2 className="text-sm font-semibold text-[#132019]">
            Have an episode ID or link?
          </h2>
          <p className="mt-1 text-xs text-[#52635a]">
            Open any episode deck directly (for example:{" "}
            <code className="rounded bg-[#f2f6f3] px-1.5 py-0.5 font-mono text-[#146c43]">
              episode-001
            </code>
            ).
          </p>
          <div className="mt-3.5">
            <EpisodeLookupForm compact />
          </div>
        </section>
      </div>
    );
  }

  const now = new Date();
  const nowIso = now.toISOString();

  // Fetch user's imported cards + episode metadata (strictly user-owned rows only)
  const [
    { count: dueCountRaw },
    { count: totalCardsRaw },
    { data: nextUpcomingRows },
    { data: userCardEpisodes },
  ] = await Promise.all([
    supabase
      .from("user_cards")
      .select("id", { count: "exact", head: true })
      .lte("due_at", nowIso),
    supabase.from("user_cards").select("id", { count: "exact", head: true }),
    supabase
      .from("user_cards")
      .select("due_at")
      .gt("due_at", nowIso)
      .order("due_at", { ascending: true })
      .limit(1),
    supabase
      .from("user_cards")
      .select(
        `
        due_at,
        cards!inner (
          episode_id,
          episodes!inner (
            id,
            title,
            topic
          )
        )
      `
      )
      .limit(500),
  ]);

  const dueCount = dueCountRaw ?? 0;
  const totalCards = totalCardsRaw ?? 0;
  const nextDueAt = nextUpcomingRows?.[0]?.due_at ?? null;

  // Summarize imported collections
  const collectionMap = new Map<
    string,
    { id: string; title: string; topic: string; total: number; due: number }
  >();

  for (const row of userCardEpisodes ?? []) {
    const card = Array.isArray(row.cards) ? row.cards[0] : row.cards;
    if (!card) continue;
    const ep = Array.isArray(card.episodes) ? card.episodes[0] : card.episodes;
    if (!ep) continue;

    const existing = collectionMap.get(ep.id) ?? {
      id: ep.id,
      title: ep.title,
      topic: ep.topic,
      total: 0,
      due: 0,
    };
    existing.total += 1;
    if (row.due_at <= nowIso) {
      existing.due += 1;
    }
    collectionMap.set(ep.id, existing);
  }

  const collections = Array.from(collectionMap.values());

  return (
    <div className="space-y-6">
      {/* Primary Due Cards Study Card */}
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-6 shadow-xs sm:p-7">
        <div className="flex items-center justify-between gap-2">
          <span className="text-xs font-semibold tracking-wide text-[#146c43] uppercase">
            Today’s Speaking Queue
          </span>
          <span className="rounded-full bg-[#f2f6f3] px-2.5 py-0.5 text-xs font-medium text-[#52635a]">
            {totalCards} {totalCards === 1 ? "card" : "cards"} in library
          </span>
        </div>

        <div className="mt-4">
          <p className="text-3xl font-bold tracking-tight text-[#132019] sm:text-4xl">
            {dueCount} {dueCount === 1 ? "card" : "cards"} due today
          </p>
          <p className="mt-1.5 text-sm leading-relaxed text-[#52635a]">
            {totalCards === 0
              ? "You haven’t imported an episode deck yet. Import Episode 001 below to start practicing."
              : dueCount > 0
              ? "Read the context, speak your response out loud, then reveal and grade."
              : nextDueAt
              ? `All due reviews complete — next card ready ${formatRelativeUpcoming(
                  nextDueAt,
                  now.getTime()
                )}.`
              : "All due reviews complete."}
          </p>
        </div>

        <div className="mt-6">
          {dueCount > 0 ? (
            <Link
              href="/review"
              className="inline-flex min-h-[52px] w-full items-center justify-center gap-2 rounded-xl bg-[#146c43] px-5 py-3 text-base font-semibold text-white transition hover:bg-[#0f5635]"
            >
              <Mic className="h-5 w-5" aria-hidden="true" />
              <span>Start Review</span>
            </Link>
          ) : totalCards === 0 ? (
            <Link
              href="/import/episode-001"
              className="inline-flex min-h-[52px] w-full items-center justify-center gap-2 rounded-xl bg-[#146c43] px-5 py-3 text-base font-semibold text-white transition hover:bg-[#0f5635]"
            >
              <span>Preview & Import Episode 001</span>
              <ArrowRight className="h-4 w-4" aria-hidden="true" />
            </Link>
          ) : (
            <div className="flex flex-col gap-2.5 sm:flex-row">
              <div className="inline-flex min-h-[48px] flex-1 items-center justify-center gap-2 rounded-xl border border-[#c8e3d2] bg-[#f4faf6] px-4 py-2.5 text-sm font-semibold text-[#146c43]">
                <CheckCircle2 className="h-4 w-4" aria-hidden="true" />
                <span>Queue caught up</span>
              </div>
              <Link
                href="/import"
                className="inline-flex min-h-[48px] flex-1 items-center justify-center gap-2 rounded-xl border border-[#dce7e0] bg-white px-4 py-2.5 text-sm font-semibold text-[#132019] hover:bg-[#f7faf8]"
              >
                <span>Import Another Deck</span>
              </Link>
            </div>
          )}
        </div>
      </section>

      {/* Imported Collections Summary */}
      <section className="space-y-3">
        <div className="flex items-center justify-between px-1">
          <h2 className="text-sm font-semibold text-[#132019]">
            My Collections ({collections.length})
          </h2>
          <Link
            href="/library"
            className="text-xs font-semibold text-[#146c43] hover:underline"
          >
            View all
          </Link>
        </div>

        {collections.length > 0 ? (
          <div className="space-y-2.5">
            {collections.slice(0, 4).map((col) => (
              <div
                key={col.id}
                className="flex items-center justify-between gap-3 rounded-2xl border border-[#dce7e0] bg-white p-4"
              >
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="rounded bg-[#f2f6f3] px-2 py-0.5 font-mono text-[11px] font-medium text-[#52635a]">
                      {col.id}
                    </span>
                    <span className="text-xs text-[#52635a]">
                      {col.total} {col.total === 1 ? "card" : "cards"}
                    </span>
                  </div>
                  <p className="mt-1 truncate text-base font-semibold text-[#132019]">
                    {col.title}
                  </p>
                </div>

                {col.due > 0 ? (
                  <Link
                    href={`/review?episode=${encodeURIComponent(col.id)}`}
                    className="inline-flex min-h-[38px] shrink-0 items-center gap-1.5 rounded-xl bg-[#eaf5ee] px-3.5 py-1.5 text-xs font-semibold text-[#146c43] hover:bg-[#d8ede0]"
                  >
                    <span>{col.due} due</span>
                    <ArrowRight className="h-3.5 w-3.5" aria-hidden="true" />
                  </Link>
                ) : (
                  <Link
                    href={`/import/${col.id}`}
                    className="inline-flex min-h-[38px] shrink-0 items-center gap-1 rounded-xl border border-[#edf2ef] px-3 py-1.5 text-xs font-medium text-[#52635a] hover:bg-[#f7faf8]"
                  >
                    <Clock className="h-3.5 w-3.5" aria-hidden="true" />
                    <span>Scheduled</span>
                  </Link>
                )}
              </div>
            ))}
          </div>
        ) : (
          <div className="rounded-2xl border border-[#dce7e0] bg-white p-5">
            <div className="flex items-start gap-3">
              <BookOpen
                className="mt-0.5 h-5 w-5 shrink-0 text-[#146c43]"
                aria-hidden="true"
              />
              <div>
                <p className="text-sm font-semibold text-[#132019]">
                  Start with Episode 001: Ordering Coffee
                </p>
                <p className="mt-0.5 text-xs leading-relaxed text-[#52635a]">
                  5 everyday café speaking cards from A2 to B2, ready to preview
                  and import.
                </p>
                <Link
                  href="/import/episode-001"
                  className="mt-3 inline-flex items-center gap-1 text-xs font-semibold text-[#146c43] hover:underline"
                >
                  <span>Open Episode 001 preview</span>
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </div>
          </div>
        )}
      </section>

      {/* Quick Import by Episode ID */}
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5">
        <h2 className="text-sm font-semibold text-[#132019]">
          Import Episode by ID
        </h2>
        <p className="mt-0.5 text-xs text-[#52635a]">
          Paste an episode link or enter an ID from a video caption.
        </p>
        <div className="mt-3">
          <EpisodeLookupForm compact />
        </div>
      </section>
    </div>
  );
}
