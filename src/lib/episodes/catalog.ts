import { z } from "zod";
import { BANK_CODE_REGEX, episodeIdSchema } from "@/lib/episodes/schema";
import { createClient } from "@/lib/supabase/client";

export const DECK_CATALOG_TTL_MS = 24 * 60 * 60 * 1000;
const STORAGE_KEY = "sayagain_deck_catalog_v2";

export type CatalogDeck = {
  id: string;
  title: string;
  topic: string;
  language: string;
  publishedAt: string | null;
  cardCount: number;
};

export type StoredCatalog = {
  fetchedAt: string;
  decks: CatalogDeck[];
};

const catalogRowSchema = z.object({
  id: episodeIdSchema,
  title: z.string().trim().min(1),
  topic: z.string(),
  language: z.string(),
  published_at: z.string().nullable(),
  card_count: z.number().int().nonnegative(),
});

const storedDeckSchema = z.object({
  id: episodeIdSchema,
  title: z.string().trim().min(1),
  topic: z.string(),
  language: z.string(),
  publishedAt: z.string().nullable(),
  cardCount: z.number().int().nonnegative(),
});

const storedCatalogSchema = z.object({
  fetchedAt: z.string().min(1),
  decks: z.array(storedDeckSchema),
});

let inflight: Promise<StoredCatalog> | null = null;

/**
 * Chooses the import path for a catalog row.
 * A bank code stored in `topic` wins over an older hashed episode id.
 * @param id - Episode id from the catalog.
 * @param topic - Episode topic, which holds `SCN-021` for published scenario decks.
 * @returns The code when the topic is a bank code, otherwise the episode id.
 */
export function deckImportId(id: string, topic: string): string {
  const code = topic.trim().toUpperCase();
  if (BANK_CODE_REGEX.test(code)) {
    return code;
  }
  return id;
}

/**
 * Orders decks newest-first. Missing dates sort last; equal dates break on id.
 * @param decks - Catalog rows to order for display.
 * @returns A new array. The input is left unchanged.
 */
export function sortCatalogDecks(decks: CatalogDeck[]): CatalogDeck[] {
  return [...decks].sort((left, right) => {
    const leftTime = publishedTime(left.publishedAt);
    const rightTime = publishedTime(right.publishedAt);
    if (leftTime !== rightTime) {
      return rightTime - leftTime;
    }
    if (left.id < right.id) return -1;
    if (left.id > right.id) return 1;
    return 0;
  });
}

/**
 * Drops rows that are not a published catalog entry.
 * @param value - JSON array from `list_published_catalog`.
 * @returns Decks safe to store on the device.
 */
export function parseCatalogDecks(value: unknown): CatalogDeck[] {
  if (!Array.isArray(value)) {
    return [];
  }
  const decks: CatalogDeck[] = [];
  for (const row of value) {
    const parsed = catalogRowSchema.safeParse(row);
    if (!parsed.success) continue;
    decks.push({
      id: parsed.data.id,
      title: parsed.data.title,
      topic: parsed.data.topic,
      language: parsed.data.language,
      publishedAt: asIsoTimestamp(parsed.data.published_at),
      cardCount: parsed.data.card_count,
    });
  }
  return decks;
}

/**
 * True when the saved list is missing a clock time or is at least a day old.
 * @param fetchedAt - ISO time stored with the catalog.
 * @param now - Current time in milliseconds.
 * @returns Whether another catalog query is allowed.
 */
export function isCatalogStale(fetchedAt: string, now: number): boolean {
  const fetched = Date.parse(fetchedAt);
  if (!Number.isFinite(fetched)) return true;
  return now - fetched >= DECK_CATALOG_TTL_MS;
}

/**
 * Short label for the disabled refresh control.
 * @param remainingMs - Milliseconds until the one-day cache expires.
 * @returns A compact wait string such as "Refresh in 14h".
 */
export function formatRefreshWait(remainingMs: number): string {
  const totalMinutes = Math.max(1, Math.ceil(remainingMs / 60_000));
  if (totalMinutes >= 60) {
    const hours = Math.ceil(totalMinutes / 60);
    return `Refresh in ${hours}h`;
  }
  return `Refresh in ${totalMinutes}m`;
}

/**
 * Reads the device catalog. Invalid JSON is treated as no cache.
 * @returns The stored snapshot, or null when nothing valid is saved.
 */
export function readStoredCatalog(): StoredCatalog | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = storedCatalogSchema.safeParse(JSON.parse(raw));
    if (!parsed.success || !Number.isFinite(Date.parse(parsed.data.fetchedAt))) {
      return null;
    }
    return {
      fetchedAt: new Date(parsed.data.fetchedAt).toISOString(),
      decks: parsed.data.decks.map((deck) => ({
        ...deck,
        publishedAt: asIsoTimestamp(deck.publishedAt),
      })),
    };
  } catch {
    return null;
  }
}

/**
 * Loads the catalog from the device when it is still inside the one-day window.
 * Otherwise runs one metadata query and replaces the saved list.
 * @param force - When true, ignores a fresh cache. Used after the day has elapsed or a failed load.
 * @returns The catalog now stored on the device.
 */
export async function loadDeckCatalog(force = false): Promise<StoredCatalog> {
  const cached = readStoredCatalog();
  if (!force && cached && !isCatalogStale(cached.fetchedAt, Date.now())) {
    return cached;
  }
  if (inflight) return inflight;
  inflight = fetchAndStoreCatalog().finally(() => {
    inflight = null;
  });
  return inflight;
}

async function fetchAndStoreCatalog(): Promise<StoredCatalog> {
  const supabase = createClient();
  const { data, error } = await supabase.rpc("list_published_catalog");
  if (error) {
    throw new Error(error.message);
  }
  const next: StoredCatalog = {
    fetchedAt: new Date().toISOString(),
    decks: sortCatalogDecks(parseCatalogDecks(data)),
  };
  writeStoredCatalog(next);
  return next;
}

function writeStoredCatalog(catalog: StoredCatalog): void {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(catalog));
}

function asIsoTimestamp(value: string | null): string | null {
  if (!value) return null;
  const time = Date.parse(value);
  if (!Number.isFinite(time)) return null;
  return new Date(time).toISOString();
}

function publishedTime(value: string | null): number {
  if (!value) return Number.NEGATIVE_INFINITY;
  const time = Date.parse(value);
  return Number.isFinite(time) ? time : Number.NEGATIVE_INFINITY;
}
