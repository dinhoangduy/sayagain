import fs from "node:fs/promises";
import path from "node:path";
import { describe, expect, it } from "vitest";
import {
  episodeExportSchema,
  extractEpisodeIdFromInput,
} from "@/lib/episodes/schema";

describe("episodeExportSchema & extractEpisodeIdFromInput", () => {
  it("validates seed content/episodes/episode-001.cards.json", async () => {
    const filePath = path.resolve(
      process.cwd(),
      "content/episodes/episode-001.cards.json"
    );
    const raw = await fs.readFile(filePath, "utf8");
    const parsed = episodeExportSchema.parse(JSON.parse(raw));

    expect(parsed.episodeId).toBe("episode-001");
    expect(parsed.title).toBe("Ordering Coffee");
    expect(parsed.status).toBe("published");
    expect(parsed.cards).toHaveLength(5);
  });

  it("rejects duplicate cardId values inside the same episode", () => {
    const invalid = episodeExportSchema.safeParse({
      episodeId: "episode-002",
      title: "At the Airport",
      language: "en-US",
      status: "published",
      cards: [
        {
          cardId: "episode-002-a2-checkin",
          level: "A2",
          context: "Check-in desk",
          prompt: "Passport and ticket, please.",
          task: "Hand over your passport politely.",
          answer: "Here is my passport, thank you.",
        },
        {
          cardId: "episode-002-a2-checkin",
          level: "B1",
          context: "Seat request",
          prompt: "Window or aisle?",
          task: "Ask for an aisle seat.",
          answer: "Could I get an aisle seat if one is available?",
        },
      ],
    });

    expect(invalid.success).toBe(false);
  });

  it("extracts episode IDs from plain strings and pasted URLs", () => {
    expect(extractEpisodeIdFromInput("episode-001")).toBe("episode-001");
    expect(extractEpisodeIdFromInput("  EPISODE-001 ")).toBe("episode-001");
    expect(
      extractEpisodeIdFromInput(
        "https://sayagain.vercel.app/import/episode-001?utm_source=tiktok"
      )
    ).toBe("episode-001");
    expect(extractEpisodeIdFromInput("invalid id with spaces")).toBeNull();
    expect(extractEpisodeIdFromInput("")).toBeNull();
  });
});
