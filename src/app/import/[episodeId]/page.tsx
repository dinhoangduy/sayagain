import type { Metadata } from "next";
import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { ArrowLeft, CheckCircle2, Layers, MessageSquare } from "lucide-react";
import { ImportDeckConfirm } from "@/components/import/ImportDeckConfirm";
import { buildLoginHref } from "@/lib/auth/redirect";
import { episodeIdSchema } from "@/lib/episodes/schema";
import { createClient } from "@/lib/supabase/server";

interface ImportEpisodePageProps {
  params: Promise<{
    episodeId: string;
  }>;
}

export async function generateMetadata({
  params,
}: ImportEpisodePageProps): Promise<Metadata> {
  const { episodeId } = await params;
  const parsed = episodeIdSchema.safeParse(episodeId);
  if (!parsed.success) {
    return { title: "Episode Not Found" };
  }

  const supabase = await createClient();
  const { data: episode } = await supabase
    .from("episodes")
    .select("title")
    .eq("id", parsed.data)
    .eq("status", "published")
    .maybeSingle();

  return {
    title: episode ? `Import: ${episode.title}` : "Episode Not Found",
  };
}

export default async function ImportEpisodePage({
  params,
}: ImportEpisodePageProps) {
  const rawParams = await params;
  const parsedId = episodeIdSchema.safeParse(rawParams.episodeId);
  if (!parsedId.success) {
    notFound();
  }

  const episodeId = parsedId.data;
  const supabase = await createClient();

  // Step 1: Validate episode exists and is published (friendly 404 before auth if invalid/unpublished)
  const { data: episode, error: episodeError } = await supabase
    .from("episodes")
    .select("id, title, topic, description, language, source_url, status")
    .eq("id", episodeId)
    .eq("status", "published")
    .maybeSingle();

  if (episodeError || !episode) {
    notFound();
  }

  // Step 2: Require authentication, preserving exact return path `/import/{episodeId}`
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect(buildLoginHref(`/import/${episode.id}`));
  }

  // Step 3: Load deck cards and current user's import state
  const { data: cards } = await supabase
    .from("cards")
    .select("id, level, context, question, task, answer, sort_order")
    .eq("episode_id", episode.id)
    .order("sort_order", { ascending: true });

  const deckCards = cards ?? [];
  const cardIds = deckCards.map((c) => c.id);

  let ownedCardIds = new Set<string>();
  let dueInEpisodeCount = 0;

  if (cardIds.length > 0) {
    const nowIso = new Date().toISOString();
    const { data: userCards } = await supabase
      .from("user_cards")
      .select("card_id, due_at")
      .in("card_id", cardIds);

    if (userCards) {
      ownedCardIds = new Set(userCards.map((uc) => uc.card_id));
      dueInEpisodeCount = userCards.filter((uc) => uc.due_at <= nowIso).length;
    }
  }

  const ownedCount = ownedCardIds.size;
  const totalCount = deckCards.length;
  const isFullyImported = totalCount > 0 && ownedCount === totalCount;

  return (
    <div className="space-y-5">
      <div>
        <Link
          href="/library"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#52635a] hover:text-[#132019]"
        >
          <ArrowLeft className="h-3.5 w-3.5" aria-hidden="true" />
          <span>My Library</span>
        </Link>
      </div>

      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div className="flex flex-wrap items-center gap-2">
            <span className="rounded-md bg-[#eaf5ee] px-2.5 py-1 font-mono text-xs font-semibold text-[#146c43]">
              {episode.id}
            </span>
            <span className="rounded-md bg-[#f2f6f3] px-2.5 py-1 text-xs font-medium text-[#52635a]">
              {episode.language}
            </span>
          </div>

          {isFullyImported ? (
            <span className="inline-flex items-center gap-1 rounded-full bg-[#eaf5ee] px-2.5 py-1 text-xs font-semibold text-[#146c43]">
              <CheckCircle2 className="h-3.5 w-3.5" aria-hidden="true" />
              <span>In Collection ({ownedCount}/{totalCount})</span>
            </span>
          ) : ownedCount > 0 ? (
            <span className="inline-flex items-center gap-1 rounded-full bg-[#fff8eb] px-2.5 py-1 text-xs font-semibold text-[#8c5808]">
              <span>
                Partially Imported ({ownedCount}/{totalCount})
              </span>
            </span>
          ) : (
            <span className="inline-flex items-center gap-1 rounded-full bg-[#f2f6f3] px-2.5 py-1 text-xs font-medium text-[#52635a]">
              <Layers className="h-3.5 w-3.5" aria-hidden="true" />
              <span>{totalCount} speaking cards</span>
            </span>
          )}
        </div>

        <h1 className="mt-3 text-2xl font-bold tracking-tight text-[#132019]">
          {episode.title}
        </h1>
        {episode.topic && (
          <p className="mt-1 text-xs font-semibold tracking-wide text-[#146c43] uppercase">
            {episode.topic}
          </p>
        )}
        {episode.description && (
          <p className="mt-2 text-sm leading-relaxed text-[#52635a]">
            {episode.description}
          </p>
        )}

        <div className="mt-5 border-t border-[#edf2ef] pt-5">
          <ImportDeckConfirm
            episodeId={episode.id}
            totalCards={totalCount}
            initiallyOwnedCount={ownedCount}
            dueInEpisodeCount={dueInEpisodeCount}
          />
        </div>
      </section>

      <section className="space-y-3">
        <div className="flex items-center justify-between px-1">
          <h2 className="text-sm font-semibold text-[#132019]">
            Deck Preview ({totalCount} {totalCount === 1 ? "Card" : "Cards"})
          </h2>
          <span className="text-xs text-[#52635a]">Speak-aloud prompts</span>
        </div>

        <ol className="space-y-3">
          {deckCards.map((card, index) => {
            const alreadyOwned = ownedCardIds.has(card.id);
            return (
              <li
                key={card.id}
                className="rounded-2xl border border-[#dce7e0] bg-white p-4 sm:p-5"
              >
                <div className="flex items-center justify-between gap-2">
                  <div className="flex items-center gap-2">
                    <span className="inline-flex h-6 min-w-[24px] items-center justify-center rounded-md bg-[#f2f6f3] px-1.5 text-xs font-bold text-[#52635a]">
                      {index + 1}
                    </span>
                    <span className="rounded-md bg-[#eaf5ee] px-2 py-0.5 text-xs font-bold text-[#146c43]">
                      {card.level}
                    </span>
                    <span className="text-xs font-medium text-[#52635a]">
                      {card.context}
                    </span>
                  </div>

                  {alreadyOwned && (
                    <span className="text-[11px] font-semibold text-[#146c43]">
                      Imported
                    </span>
                  )}
                </div>

                <div className="mt-3 space-y-2">
                  <div className="flex items-start gap-2">
                    <MessageSquare
                      className="mt-0.5 h-4 w-4 shrink-0 text-[#52635a]"
                      aria-hidden="true"
                    />
                    <p className="text-sm font-semibold text-[#132019]">
                      “{card.question}”
                    </p>
                  </div>
                  <p className="rounded-xl bg-[#f7faf8] px-3 py-2 text-xs leading-relaxed text-[#355443]">
                    <span className="font-semibold text-[#146c43]">
                      Speaking task:
                    </span>{" "}
                    {card.task}
                  </p>
                </div>
              </li>
            );
          })}
        </ol>
      </section>
    </div>
  );
}
