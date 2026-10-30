"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  AlertCircle,
  CheckCircle2,
  Download,
  Loader2,
  Mic,
  RefreshCw,
} from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import type { ImportEpisodeDeckResult } from "@/lib/supabase/database.types";

interface ImportDeckConfirmProps {
  episodeId: string;
  totalCards: number;
  initiallyOwnedCount: number;
  dueInEpisodeCount: number;
}

export function ImportDeckConfirm({
  episodeId,
  totalCards,
  initiallyOwnedCount,
  dueInEpisodeCount,
}: ImportDeckConfirmProps) {
  const router = useRouter();
  const [importing, setImporting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<ImportEpisodeDeckResult | null>(null);

  const ownedCount = result ? result.total_cards : initiallyOwnedCount;
  const allImported = totalCards > 0 && ownedCount >= totalCards;

  const handleConfirmImport = async () => {
    if (importing) return;
    setImporting(true);
    setError(null);

    try {
      const supabase = createClient();
      const { data, error: rpcError } = await supabase.rpc(
        "import_episode_deck",
        {
          p_episode_id: episodeId,
        }
      );

      if (rpcError || !data) {
        throw new Error(
          rpcError?.message ||
            "Could not import this episode right now. Please try again."
        );
      }

      const parsed = data as unknown as ImportEpisodeDeckResult;
      setResult(parsed);
      router.refresh();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "Network error while importing deck. Please retry."
      );
    } finally {
      setImporting(false);
    }
  };

  return (
    <div className="space-y-3">
      {result && (
        <div
          role="status"
          className="rounded-xl border border-[#b9dcc7] bg-[#eaf5ee] p-4 text-sm text-[#133824]"
        >
          <div className="flex items-start gap-2.5">
            <CheckCircle2
              className="mt-0.5 h-5 w-5 shrink-0 text-[#146c43]"
              aria-hidden="true"
            />
            <div className="space-y-1">
              <p className="font-semibold text-[#132019]">
                {result.added_count > 0
                  ? `Imported ${result.added_count} new ${
                      result.added_count === 1 ? "card" : "cards"
                    } to your collection`
                  : "Deck already in your collection"}
              </p>
              <p className="text-xs leading-relaxed text-[#355443]">
                {result.existing_count > 0
                  ? `${result.existing_count} existing ${
                      result.existing_count === 1 ? "card was" : "cards were"
                    } kept untouched with your spaced-repetition progress preserved.`
                  : "All cards are now ready in your review queue."}
              </p>
            </div>
          </div>
        </div>
      )}

      {error && (
        <div
          role="alert"
          className="flex items-start justify-between gap-3 rounded-xl border border-[#f2c6c6] bg-[#fff5f5] p-3.5 text-xs text-[#9b2c2c]"
        >
          <div className="flex items-start gap-2">
            <AlertCircle
              className="mt-0.5 h-4 w-4 shrink-0"
              aria-hidden="true"
            />
            <p className="leading-relaxed">{error}</p>
          </div>
          <button
            type="button"
            onClick={handleConfirmImport}
            disabled={importing}
            className="inline-flex shrink-0 items-center gap-1 rounded-lg border border-[#e5a3a3] bg-white px-2.5 py-1 font-semibold text-[#9b2c2c] hover:bg-[#fff0f0]"
          >
            <RefreshCw className="h-3 w-3" />
            <span>Retry</span>
          </button>
        </div>
      )}

      <div className="flex flex-col gap-2.5 sm:flex-row">
        {!allImported || !result ? (
          <button
            type="button"
            onClick={handleConfirmImport}
            disabled={importing}
            className={`inline-flex min-h-[48px] flex-1 cursor-pointer items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-semibold transition disabled:opacity-60 ${
              allImported
                ? "border border-[#c8e3d2] bg-[#f4faf6] text-[#146c43] hover:bg-[#eaf5ee]"
                : "bg-[#146c43] text-white hover:bg-[#0f5635]"
            }`}
          >
            {importing ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
                <span>Importing Deck…</span>
              </>
            ) : allImported ? (
              <>
                <RefreshCw className="h-4 w-4" aria-hidden="true" />
                <span>Re-check Deck (Keeps Progress)</span>
              </>
            ) : initiallyOwnedCount > 0 ? (
              <>
                <Download className="h-4 w-4" aria-hidden="true" />
                <span>
                  Import {totalCards - initiallyOwnedCount} Missing Cards
                </span>
              </>
            ) : (
              <>
                <Download className="h-4 w-4" aria-hidden="true" />
                <span>Import to My Collection</span>
              </>
            )}
          </button>
        ) : null}

        {(allImported || result) && (
          <Link
            href={
              dueInEpisodeCount > 0 || (result?.added_count ?? 0) > 0
                ? `/review?episode=${encodeURIComponent(episodeId)}`
                : "/review"
            }
            className="inline-flex min-h-[48px] flex-1 items-center justify-center gap-2 rounded-xl bg-[#146c43] px-4 py-3 text-sm font-semibold text-white transition hover:bg-[#0f5635]"
          >
            <Mic className="h-4 w-4" aria-hidden="true" />
            <span>Start Practice</span>
          </Link>
        )}
      </div>
    </div>
  );
}
