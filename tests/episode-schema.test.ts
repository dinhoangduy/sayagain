import fs from "node:fs/promises";
import path from "node:path";
import { describe, expect, it } from "vitest";
import {
  episodeExportSchema,
  extractEpisodeIdFromInput,
  toStoredCardDraft,
} from "@/lib/episodes/schema";

describe("episodeExportSchema & extractEpisodeIdFromInput", () => {
  it("validates seed content/episodes/episode-001.cards.json", async () => {
    const filePath = path.resolve(
      process.cwd(),
      "content/episodes/episode-001.cards.json"
    );
    const raw = await fs.readFile(filePath, "utf8");
    const parsed = episodeExportSchema.parse(JSON.parse(raw));

    expect(parsed.episodeId).toBe("db70b939405121f61a0f82b6");
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

  it("stores a framework card as a situation, a question, and three labeled answers", () => {
    const parsed = episodeExportSchema.parse({
      episodeId: "scn-001-unrealistic-deadline",
      title: "An Unrealistic Deadline",
      topic: "SCN-001",
      description: "Your manager assigns a report due tomorrow.",
      language: "en-US",
      status: "published",
      cards: [
        {
          cardId: "scn-001-unrealistic-deadline",
          situation:
            "Your manager assigns a report due tomorrow, but you already have two urgent tasks.",
          question: "Can you finish this by tomorrow?",
          framework: {
            id: "capacity-constraint-proposal",
            name: "Capacity → Constraint → Proposal",
            steps: [
              {
                label: "Capacity",
                answer: "I can get started on it today.",
              },
              {
                label: "Constraint",
                answer: "I'm already juggling two urgent tasks, though.",
              },
              {
                label: "Proposal",
                answer: "Could we make Thursday the deadline instead?",
              },
            ],
          },
        },
      ],
    });

    const stored = toStoredCardDraft(parsed.cards[0]);
    expect(stored.level).toBeNull();
    expect(stored.context).toContain("two urgent tasks");
    expect(stored.question).toBe("Can you finish this by tomorrow?");
    expect(stored.task).toBe("Capacity → Constraint → Proposal");
    expect(stored.framework?.steps.map((step) => step.label)).toEqual([
      "Capacity",
      "Constraint",
      "Proposal",
    ]);
    expect(stored.answer).toBe(
      "I can get started on it today. I'm already juggling two urgent tasks, though. Could we make Thursday the deadline instead?"
    );
  });

  it("rejects a framework that does not have exactly three steps", () => {
    const invalid = episodeExportSchema.safeParse({
      episodeId: "scn-002",
      title: "Too few steps",
      status: "published",
      cards: [
        {
          cardId: "scn-002",
          situation: "A short situation.",
          question: "What do you say?",
          framework: {
            id: "status-blocker-eta",
            name: "Status → Blocker → ETA",
            steps: [
              { label: "Status", answer: "I can start today." },
              { label: "Blocker", answer: "Two other tasks are already urgent." },
            ],
          },
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
    expect(extractEpisodeIdFromInput("scn-001")).toBe("SCN-001");
    expect(
      extractEpisodeIdFromInput("https://sayagain.app/import/CSF-052")
    ).toBe("CSF-052");
    expect(extractEpisodeIdFromInput("invalid id with spaces")).toBeNull();
    expect(extractEpisodeIdFromInput("")).toBeNull();
  });

  it("keeps a bank code as the deck id and stores follow-up deck links", () => {
    const parsed = episodeExportSchema.parse({
      episodeId: "scn-001",
      title: "An unrealistic deadline",
      topic: "SCN-001",
      status: "published",
      cards: [
        {
          cardId: "SCN-001",
          situation: "Your manager assigns a report due tomorrow.",
          question: "Can you finish this by tomorrow?",
          framework: {
            id: "capacity-constraint-proposal",
            name: "Capacity → Constraint → Proposal",
            steps: [
              { label: "Capacity", answer: "I can start on it today." },
              { label: "Constraint", answer: "I've already got two urgent tasks." },
              { label: "Proposal", answer: "Could we push it to Thursday?" },
            ],
          },
          followUps: [
            {
              speaker: "Manager",
              question: "Thursday is too late. What could you deliver by tomorrow?",
              decks: [
                { code: "csf-052", phrase: "Would it work if..." },
                { code: "CSF-058", phrase: "Here's what I can do." },
              ],
            },
          ],
        },
      ],
    });

    expect(parsed.episodeId).toBe("SCN-001");
    expect(parsed.cards[0].cardId).toBe("SCN-001");
    const stored = toStoredCardDraft(parsed.cards[0]);
    expect(stored.followUps[0]?.decks.map((deck) => deck.code)).toEqual([
      "CSF-052",
      "CSF-058",
    ]);
  });
});
