"use client";

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import { ReviewSession } from "@/components/review/ReviewSession";
import { useStudy } from "@/lib/study/store";

/**
 * Review queue from the on-device collection. Grades stay local until Sync.
 * @returns The speaking session, or a placeholder while the cache is opening.
 */
export function ReviewScreen() {
  const study = useStudy();
  const params = useSearchParams();
  const episodeId = params.get("episode");
  const dueItems = useMemo(() => {
    const nowIso = new Date().toISOString();
    return study.items.filter((item) => {
      if (item.userCard.due_at > nowIso) return false;
      if (episodeId && item.episode.id !== episodeId) return false;
      return true;
    });
  }, [episodeId, study.items]);
  const totalDue = useMemo(() => {
    const nowIso = new Date().toISOString();
    return study.items.filter((item) => item.userCard.due_at <= nowIso).length;
  }, [study.items]);

  if (!study.ready) {
    return (
      <div className="h-48 animate-pulse rounded-2xl border border-[#dce7e0] bg-white shadow-xs" />
    );
  }

  return (
    <ReviewSession
      initialQueue={dueItems}
      filteredEpisodeId={episodeId}
      totalDueAllEpisodes={totalDue}
    />
  );
}
