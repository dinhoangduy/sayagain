"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { RefreshCw } from "lucide-react";
import {
  DECK_CATALOG_TTL_MS,
  deckImportId,
  formatRefreshWait,
  isCatalogStale,
  loadDeckCatalog,
  readStoredCatalog,
  type StoredCatalog,
} from "@/lib/episodes/catalog";
import {
  NEW_CARD_LIMIT,
  canAddNewCards,
  cardsThatWouldBeNew,
  countNewCards,
} from "@/lib/study/newCards";
import { useStudy } from "@/lib/study/store";

type LoadStatus = "loading" | "ready" | "error";

/**
 * Published decks under the import form. One query per device per day.
 * @returns The cached catalog, a refresh control, and links into each deck.
 */
export function AvailableDecks() {
  const study = useStudy();
  const [catalog, setCatalog] = useState<StoredCatalog | null>(null);
  const [status, setStatus] = useState<LoadStatus>("loading");
  const [error, setError] = useState<string | null>(null);
  const [now, setNow] = useState(0);
  const [reloadToken, setReloadToken] = useState(0);

  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 60_000);
    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    let cancelled = false;
    const cached = readStoredCatalog();
    if (cached) setCatalog(cached);

    const current = Date.now();
    setNow(current);
    const needsFetch = !cached || isCatalogStale(cached.fetchedAt, current);
    if (!needsFetch) {
      setStatus("ready");
      setError(null);
      return;
    }

    setStatus("loading");
    loadDeckCatalog(true)
      .then((next) => {
        if (cancelled) return;
        setCatalog(next);
        setStatus("ready");
        setError(null);
      })
      .catch(() => {
        if (cancelled) return;
        setStatus(cached ? "ready" : "error");
        setError(
          cached
            ? "Could not refresh the deck list. The saved copy is unchanged."
            : "Could not load the deck list.",
        );
      });

    return () => {
      cancelled = true;
    };
  }, [reloadToken]);

  const ownedByEpisode = useMemo(() => {
    const counts = new Map<string, number>();
    for (const item of study.items) {
      counts.set(item.episode.id, (counts.get(item.episode.id) ?? 0) + 1);
    }
    return counts;
  }, [study.items]);

  const newCount = countNewCards(study.items.map((item) => item.userCard.fsrs_state));

  const fetchedAt = catalog ? Date.parse(catalog.fetchedAt) : Number.NaN;
  const remainingMs =
    catalog && Number.isFinite(fetchedAt)
      ? DECK_CATALOG_TTL_MS - (now - fetchedAt)
      : 0;
  const refreshLocked = Boolean(catalog) && remainingMs > 0 && !error;
  const showLoading = status === "loading" && !catalog;

  const refreshLabel = refreshLocked
    ? formatRefreshWait(remainingMs)
    : status === "loading"
      ? "Refreshing…"
      : "Refresh list";

  return (
    <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-bold tracking-tight text-[#132019]">
            Available decks
          </h2>
          <p className="mt-1 text-sm leading-relaxed text-[#52635a]">
            Saved on this device and refreshed once a day.
            {study.ready
              ? ` You can hold ${NEW_CARD_LIMIT} new cards. ${newCount} of those slots are in use.`
              : ""}
          </p>
        </div>
        <button
          type="button"
          disabled={refreshLocked || status === "loading"}
          onClick={() => setReloadToken((token) => token + 1)}
          className="inline-flex min-h-[40px] shrink-0 cursor-pointer items-center gap-1.5 rounded-xl border border-[#cddcd3] bg-white px-3 py-2 text-xs font-semibold text-[#132019] transition hover:bg-[#f7faf8] disabled:cursor-not-allowed disabled:text-[#788a80] disabled:hover:bg-white"
        >
          <RefreshCw
            className={`h-3.5 w-3.5 ${status === "loading" ? "animate-spin" : ""}`}
            aria-hidden="true"
          />
          <span>{refreshLabel}</span>
        </button>
      </div>

      {error && (
        <p role="alert" className="mt-3 text-xs font-medium text-[#9b2c2c]">
          {error}
        </p>
      )}

      {showLoading ? (
        <div className="mt-4 h-28 animate-pulse rounded-xl bg-[#f2f6f3]" />
      ) : catalog && catalog.decks.length > 0 ? (
        <ul className="mt-4 divide-y divide-[#edf2ef] rounded-xl border border-[#edf2ef]">
          {catalog.decks.map((deck) => {
            const importId = deckImportId(deck.id, deck.topic);
            const owned =
              ownedByEpisode.get(importId) ?? ownedByEpisode.get(deck.id) ?? 0;
            const imported = deck.cardCount > 0 && owned >= deck.cardCount;
            const adding = cardsThatWouldBeNew(deck.cardCount, owned);
            const blocked =
              study.ready && !canAddNewCards(newCount, adding);
            return (
              <li key={deck.id}>
                <Link
                  href={`/import/${importId}`}
                  className="flex items-center justify-between gap-3 px-3.5 py-3 transition hover:bg-[#f7faf8]"
                >
                  <span className="min-w-0">
                    <span className="flex flex-wrap items-center gap-2">
                      <span className="truncate text-sm font-semibold text-[#132019]">
                        {deck.title}
                      </span>
                      {imported && (
                        <span className="rounded-full bg-[#f2f6f3] px-2 py-0.5 text-[10px] font-semibold tracking-wide text-[#52635a] uppercase">
                          Imported
                        </span>
                      )}
                      {blocked && (
                        <span className="rounded-full bg-[#fff8eb] px-2 py-0.5 text-[10px] font-semibold tracking-wide text-[#8c5808] uppercase">
                          Practice first
                        </span>
                      )}
                    </span>
                    {deck.topic && (
                      <span className="mt-0.5 block truncate text-xs text-[#52635a]">
                        {deck.topic}
                      </span>
                    )}
                  </span>
                  <span
                    className={`shrink-0 text-xs font-semibold ${
                      blocked ? "text-[#8c5808]" : "text-[#146c43]"
                    }`}
                  >
                    {blocked ? "Locked" : "Preview"}
                  </span>
                </Link>
              </li>
            );
          })}
        </ul>
      ) : status === "ready" ? (
        <p className="mt-4 text-sm text-[#52635a]">No published decks yet.</p>
      ) : null}
    </section>
  );
}
