import { z } from "zod";

export const EPISODE_ID_REGEX = /^[a-z0-9][a-z0-9-]{1,63}$/;
export const CARD_ID_REGEX = /^[a-z0-9][a-z0-9-]{1,95}$/;

export const cefrLevelSchema = z.enum(["A1", "A2", "B1", "B2", "C1", "C2"]);
export type CefrLevel = z.infer<typeof cefrLevelSchema>;

export const episodeStatusSchema = z.enum(["draft", "published", "archived"]);
export type EpisodeStatus = z.infer<typeof episodeStatusSchema>;

export const episodeIdSchema = z
  .string()
  .trim()
  .toLowerCase()
  .regex(
    EPISODE_ID_REGEX,
    "Episode ID must be 2–64 lowercase letters, digits, or hyphens (e.g. episode-001)."
  );

export const cardIdSchema = z
  .string()
  .trim()
  .toLowerCase()
  .regex(
    CARD_ID_REGEX,
    "Card ID must be 2–96 lowercase letters, digits, or hyphens."
  );

export const exportedCardSchema = z.object({
  cardId: cardIdSchema,
  level: cefrLevelSchema,
  context: z.string().trim().min(1).max(200),
  prompt: z.string().trim().min(1).max(500),
  task: z.string().trim().min(1).max(500),
  answer: z.string().trim().min(1).max(500),
  audioUrl: z
    .string()
    .trim()
    .refine(
      (val) => val.startsWith("/") || val.startsWith("https://"),
      "audioUrl must be a relative '/audio/...' path or an 'https://' URL."
    )
    .nullable()
    .optional(),
  contentVersion: z.number().int().min(1).default(1),
});

export const episodeExportSchema = z
  .object({
    episodeId: episodeIdSchema,
    title: z.string().trim().min(1).max(140),
    topic: z.string().trim().max(140).optional().default(""),
    description: z.string().trim().max(500).optional().default(""),
    language: z.string().trim().min(2).max(20).default("en-US"),
    sourceUrl: z.string().url().nullable().optional(),
    status: episodeStatusSchema,
    cards: z.array(exportedCardSchema).min(1).max(50),
  })
  .superRefine((episode, ctx) => {
    const seen = new Set<string>();
    episode.cards.forEach((card, index) => {
      if (seen.has(card.cardId)) {
        ctx.addIssue({
          code: "custom",
          path: ["cards", index, "cardId"],
          message: `Duplicate cardId '${card.cardId}' within episode '${episode.episodeId}'.`,
        });
      }
      seen.add(card.cardId);
    });
  });

export type ExportedCard = z.infer<typeof exportedCardSchema>;
export type EpisodeExport = z.infer<typeof episodeExportSchema>;

/**
 * Extracts and validates an episodeId from either a plain ID ("episode-001")
 * or a pasted SayAgain import link ("https://.../import/episode-001").
 */
export function extractEpisodeIdFromInput(rawInput: string): string | null {
  const trimmed = rawInput.trim();
  if (!trimmed) {
    return null;
  }

  let candidate = trimmed.toLowerCase();

  // Check if user pasted a URL or path containing /import/<id>
  const pathMatch = trimmed.match(/\/import\/([a-zA-Z0-9-]+)(?:[/?#]|$)/);
  if (pathMatch?.[1]) {
    candidate = pathMatch[1].toLowerCase();
  }

  const parsed = episodeIdSchema.safeParse(candidate);
  return parsed.success ? parsed.data : null;
}
