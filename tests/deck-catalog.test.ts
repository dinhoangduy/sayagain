import { describe, expect, it } from "vitest";
import {
  DECK_CATALOG_TTL_MS,
  formatRefreshWait,
  isCatalogStale,
  parseCatalogDecks,
  sortCatalogDecks,
  type CatalogDeck,
} from "@/lib/episodes/catalog";
import {
  canAddNewCards,
  cardsThatWouldBeNew,
  newCardImportBlockReason,
} from "@/lib/study/newCards";

function deck(id: string, publishedAt: string | null, cardCount = 1): CatalogDeck {
  return {
    id,
    title: id,
    topic: "",
    language: "en-US",
    publishedAt,
    cardCount,
  };
}

describe("deck catalog cache", () => {
  it("keeps valid rows and drops malformed ones", () => {
    const decks = parseCatalogDecks([
      {
        id: "db70b939405121f61a0f82b6",
        title: "Ordering Coffee",
        topic: "Cafe",
        language: "en-US",
        published_at: "2026-10-01T00:00:00.000Z",
        card_count: 5,
      },
      { id: "bad id", title: "Skip" },
      "nope",
    ]);

    expect(decks).toEqual([
      {
        id: "db70b939405121f61a0f82b6",
        title: "Ordering Coffee",
        topic: "Cafe",
        language: "en-US",
        publishedAt: "2026-10-01T00:00:00.000Z",
        cardCount: 5,
      },
    ]);
  });

  it("sorts decks without a publish date last", () => {
    const decks = [
      deck("deck-old", null),
      deck("deck-06", "2026-10-06T00:00:00.000Z"),
    ];

    expect(sortCatalogDecks(decks).map((item) => item.id)).toEqual([
      "deck-06",
      "deck-old",
    ]);
  });

  it("stops an import that would leave more than five new cards", () => {
    expect(cardsThatWouldBeNew(5, 0)).toBe(5);
    expect(cardsThatWouldBeNew(5, 5)).toBe(0);
    expect(canAddNewCards(0, 5)).toBe(true);
    expect(canAddNewCards(5, 1)).toBe(false);
    expect(canAddNewCards(5, 0)).toBe(true);
    expect(canAddNewCards(3, 3)).toBe(false);
    expect(newCardImportBlockReason(5, 2)).toMatch(/5 new cards/);
    expect(newCardImportBlockReason(4, 2)).toMatch(/1 open slot/);
  });

  it("allows another query only after one day", () => {
    const fetchedAt = "2026-10-30T00:00:00.000Z";
    const fetched = Date.parse(fetchedAt);

    expect(isCatalogStale(fetchedAt, fetched + DECK_CATALOG_TTL_MS - 1)).toBe(
      false,
    );
    expect(isCatalogStale(fetchedAt, fetched + DECK_CATALOG_TTL_MS)).toBe(true);
    expect(formatRefreshWait(14 * 60 * 60 * 1000)).toBe("Refresh in 14h");
    expect(formatRefreshWait(20 * 60 * 1000)).toBe("Refresh in 20m");
  });
});
