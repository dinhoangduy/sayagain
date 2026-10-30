import type { Metadata } from "next";
import { redirect } from "next/navigation";
import {
  ReviewSession,
  type DueReviewItem,
} from "@/components/review/ReviewSession";
import { buildLoginHref } from "@/lib/auth/redirect";
import { episodeIdSchema } from "@/lib/episodes/schema";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "Review Due Cards",
};

interface ReviewPageProps {
  searchParams: Promise<{
    episode?: string;
  }>;
}

export default async function ReviewPage({ searchParams }: ReviewPageProps) {
  const params = await searchParams;
  const parsedEpisode = params.episode
    ? episodeIdSchema.safeParse(params.episode)
    : null;
  const filteredEpisodeId = parsedEpisode?.success ? parsedEpisode.data : null;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    const nextPath = filteredEpisodeId
      ? `/review?episode=${encodeURIComponent(filteredEpisodeId)}`
      : "/review";
    redirect(buildLoginHref(nextPath));
  }

  const nowIso = new Date().toISOString();

  // Count total due cards across all imported episodes
  const { count: totalDueCount } = await supabase
    .from("user_cards")
    .select("id", { count: "exact", head: true })
    .lte("due_at", nowIso);

  // Fetch due user_cards joined with published card & episode metadata
  const { data: rows } = await supabase
    .from("user_cards")
    .select(
      `
      id,
      user_id,
      card_id,
      due_at,
      last_review_at,
      fsrs_state,
      stability,
      difficulty,
      elapsed_days,
      scheduled_days,
      learning_steps,
      reps,
      lapses,
      version,
      created_at,
      updated_at,
      cards!inner (
        id,
        episode_id,
        level,
        context,
        question,
        task,
        answer,
        audio_url,
        sort_order,
        episodes!inner (
          id,
          title,
          language,
          status
        )
      )
    `
    )
    .lte("due_at", nowIso)
    .order("due_at", { ascending: true })
    .limit(50);

  const dueItems: DueReviewItem[] = [];

  for (const row of rows ?? []) {
    const cardData = Array.isArray(row.cards) ? row.cards[0] : row.cards;
    if (!cardData) continue;

    const episodeData = Array.isArray(cardData.episodes)
      ? cardData.episodes[0]
      : cardData.episodes;
    if (!episodeData || episodeData.status !== "published") continue;

    if (filteredEpisodeId && episodeData.id !== filteredEpisodeId) {
      continue;
    }

    dueItems.push({
      userCard: {
        id: row.id,
        user_id: row.user_id,
        card_id: row.card_id,
        due_at: row.due_at,
        last_review_at: row.last_review_at,
        fsrs_state: row.fsrs_state,
        stability: row.stability,
        difficulty: row.difficulty,
        elapsed_days: row.elapsed_days,
        scheduled_days: row.scheduled_days,
        learning_steps: row.learning_steps,
        reps: row.reps,
        lapses: row.lapses,
        version: row.version,
        created_at: row.created_at,
        updated_at: row.updated_at,
      },
      card: {
        id: cardData.id,
        episode_id: cardData.episode_id,
        level: cardData.level,
        context: cardData.context,
        question: cardData.question,
        task: cardData.task,
        answer: cardData.answer,
        audio_url: cardData.audio_url,
      },
      episode: {
        id: episodeData.id,
        title: episodeData.title,
        language: episodeData.language,
      },
    });
  }

  return (
    <ReviewSession
      initialQueue={dueItems}
      filteredEpisodeId={filteredEpisodeId}
      totalDueAllEpisodes={totalDueCount ?? 0}
    />
  );
}
