import { z } from "zod";

export const EPISODE_ID_REGEX = /^[a-z0-9][a-z0-9-]{1,63}$/;
export const CARD_ID_REGEX = /^[a-z0-9][a-z0-9-]{1,95}$/;
export const BANK_CODE_REGEX = /^(SCN|CSF|PIC)-\d{3}$/;

/**
 * Turns a typed id or bank code into the value stored on the episode.
 * `scn-001` becomes `SCN-001`. Older lowercase ids stay lowercase.
 * @param raw - Episode id, bank code, or path segment.
 * @returns Canonical id, or null when the text is not an id.
 */
export function canonicalEpisodeId(raw: string): string | null {
  const trimmed = raw.trim();
  if (!trimmed) {
    return null;
  }
  const code = trimmed.toUpperCase();
  if (BANK_CODE_REGEX.test(code)) {
    return code;
  }
  const lower = trimmed.toLowerCase();
  if (EPISODE_ID_REGEX.test(lower) && lower.length <= 64) {
    return lower;
  }
  return null;
}

/**
 * Canonical card id. Bank codes stay uppercase; other ids stay lowercase.
 * @param raw - Card id from a publish payload.
 * @returns Canonical id, or null when the text is not a card id.
 */
export function canonicalCardId(raw: string): string | null {
  const trimmed = raw.trim();
  if (!trimmed) {
    return null;
  }
  const code = trimmed.toUpperCase();
  if (BANK_CODE_REGEX.test(code)) {
    return code;
  }
  const lower = trimmed.toLowerCase();
  if (CARD_ID_REGEX.test(lower)) {
    return lower;
  }
  return null;
}

export const cefrLevelSchema = z.enum(["A1", "A2", "B1", "B2", "C1", "C2"]);
export type CefrLevel = z.infer<typeof cefrLevelSchema>;

export const episodeStatusSchema = z.enum(["draft", "published", "archived"]);
export type EpisodeStatus = z.infer<typeof episodeStatusSchema>;

export const episodeIdSchema = z
  .string()
  .trim()
  .superRefine((value, ctx) => {
    if (!canonicalEpisodeId(value)) {
      ctx.addIssue({
        code: "custom",
        message:
          "Episode ID must be a code like SCN-001, or 2–64 lowercase letters, digits, or hyphens.",
      });
    }
  })
  .transform((value) => canonicalEpisodeId(value) as string);

export const cardIdSchema = z
  .string()
  .trim()
  .superRefine((value, ctx) => {
    if (!canonicalCardId(value)) {
      ctx.addIssue({
        code: "custom",
        message:
          "Card ID must be a code like SCN-001, or 2–96 lowercase letters, digits, or hyphens.",
      });
    }
  })
  .transform((value) => canonicalCardId(value) as string);

const mediaUrlSchema = z
  .string()
  .trim()
  .refine(
    (val) => val.startsWith("/") || val.startsWith("https://"),
    "Media URL must be a relative path or an https URL."
  );

export const cardFrameworkStepSchema = z.object({
  label: z.string().trim().min(1).max(80),
  answer: z.string().trim().min(1).max(500),
});
export type CardFrameworkStep = z.infer<typeof cardFrameworkStepSchema>;

/**
 * Three labeled sentences that form one spoken reply.
 * The front of the card shows the labels. Reveal fills in each answer.
 */
export const cardFrameworkSchema = z.object({
  id: z.string().trim().min(1).max(80),
  name: z.string().trim().min(1).max(160),
  steps: z.array(cardFrameworkStepSchema).length(3),
});
export type CardFramework = z.infer<typeof cardFrameworkSchema>;

export const followUpDeckSchema = z.object({
  code: z
    .string()
    .trim()
    .transform((value) => value.toUpperCase())
    .refine((value) => BANK_CODE_REGEX.test(value), "Deck code must look like CSF-052."),
  phrase: z.string().trim().min(1).max(180),
});
export type FollowUpDeck = z.infer<typeof followUpDeckSchema>;

/**
 * A next question shown under a card, with links to the decks that practice it.
 */
export const cardFollowUpSchema = z.object({
  speaker: z.string().trim().min(1).max(80),
  question: z.string().trim().min(1).max(500),
  decks: z.array(followUpDeckSchema).min(1).max(3),
});
export type CardFollowUp = z.infer<typeof cardFollowUpSchema>;

const imageUploadSchema = z.object({
  contentType: z.enum(["image/jpeg", "image/png", "image/webp"]),
  dataBase64: z.string().trim().min(1).max(7_000_000),
});
export type CardImageUpload = z.infer<typeof imageUploadSchema>;

const legacyCardSchema = z.object({
  cardId: cardIdSchema,
  level: cefrLevelSchema,
  context: z.string().trim().min(1).max(200),
  prompt: z.string().trim().min(1).max(500),
  task: z.string().trim().min(1).max(500),
  answer: z.string().trim().min(1).max(500),
  audioUrl: mediaUrlSchema.nullable().optional(),
  contentVersion: z.number().int().min(1).default(1),
});

const frameworkCardSchema = z.object({
  cardId: cardIdSchema,
  situation: z.string().trim().min(1).max(800),
  question: z.string().trim().min(1).max(500),
  framework: cardFrameworkSchema,
  followUps: z.array(cardFollowUpSchema).max(3).optional(),
  imageUrl: mediaUrlSchema.nullable().optional(),
  image: imageUploadSchema.optional(),
  audioUrl: mediaUrlSchema.nullable().optional(),
  contentVersion: z.number().int().min(1).default(1),
});

export const exportedCardSchema = z.union([
  frameworkCardSchema,
  legacyCardSchema,
]);

export const episodeExportSchema = z
  .object({
    episodeId: episodeIdSchema,
    title: z.string().trim().min(1).max(140),
    topic: z.string().trim().max(140).optional().default(""),
    description: z.string().trim().max(800).optional().default(""),
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

export type StoredCardDraft = {
  id: string;
  level: string | null;
  context: string;
  question: string;
  task: string;
  answer: string;
  audioUrl: string | null;
  imageUrl: string | null;
  framework: CardFramework | null;
  followUps: CardFollowUp[];
  contentVersion: number;
  image: CardImageUpload | null;
};

/**
 * Maps one exported card onto the columns stored in `cards`.
 * Framework cards keep the three step answers structured and also join them
 * into `answer` so text-to-speech can read the full reply.
 * @param card - Validated legacy prompt card or framework card.
 * @returns Flat fields ready to insert, plus an optional image upload.
 */
export function toStoredCardDraft(card: ExportedCard): StoredCardDraft {
  if ("framework" in card) {
    return {
      id: card.cardId,
      level: null,
      context: card.situation,
      question: card.question,
      task: card.framework.name,
      answer: card.framework.steps.map((step) => step.answer).join(" "),
      audioUrl: card.audioUrl ?? null,
      imageUrl: card.imageUrl ?? null,
      framework: card.framework,
      followUps: card.followUps ?? [],
      contentVersion: card.contentVersion,
      image: card.image ?? null,
    };
  }

  return {
    id: card.cardId,
    level: card.level,
    context: card.context,
    question: card.prompt,
    task: card.task,
    answer: card.answer,
    audioUrl: card.audioUrl ?? null,
    imageUrl: null,
    framework: null,
    followUps: [],
    contentVersion: card.contentVersion,
    image: null,
  };
}

/**
 * Reads follow-up questions stored as jsonb. A bad value becomes an empty list
 * so review still opens.
 * @param value - Raw `cards.follow_ups` value, or the camelCase field on a cached card.
 * @returns Parsed questions. Invalid entries are dropped.
 */
export function parseCardFollowUps(value: unknown): CardFollowUp[] {
  const parsed = z.array(cardFollowUpSchema).max(3).safeParse(value);
  return parsed.success ? parsed.data : [];
}

/**
 * Reads a framework object stored as jsonb. Invalid shapes become null so a
 * bad row falls back to the single-answer card instead of crashing review.
 * @param value - Raw `cards.framework` value from Postgres.
 * @returns Parsed framework, or null when the value is missing or invalid.
 */
export function parseCardFramework(value: unknown): CardFramework | null {
  const parsed = cardFrameworkSchema.safeParse(value);
  return parsed.success ? parsed.data : null;
}

const publishedDeckSchema = z.object({
  episode: z.object({
    id: z.string(),
    title: z.string(),
    topic: z.string(),
    description: z.string(),
    language: z.string(),
    source_url: z.string().nullable(),
    status: z.string(),
  }),
  cards: z.array(
    z.object({
      id: z.string(),
      level: z.string().nullable(),
      context: z.string(),
      question: z.string(),
      task: z.string(),
      answer: z.string(),
      image_url: z.string().nullable(),
      framework: z.unknown(),
      follow_ups: z.unknown().nullable().optional(),
      sort_order: z.number(),
    }),
  ),
});

export type PublishedDeck = z.infer<typeof publishedDeckSchema>;

/**
 * Reads the one-deck payload from `get_published_deck`.
 * @param value - JSON returned by the RPC, or null when the id is unknown.
 * @returns The episode and its cards, or null when the payload is missing or invalid.
 */
export function parsePublishedDeck(value: unknown): PublishedDeck | null {
  if (value == null) {
    return null;
  }
  const parsed = publishedDeckSchema.safeParse(value);
  return parsed.success ? parsed.data : null;
}

/**
 * Extracts and validates an episode id from a plain id or a pasted import link.
 * @param rawInput - Episode id or import URL typed by the learner.
 * @returns Normalized episode id, or null when the input is not an id.
 */
export function extractEpisodeIdFromInput(rawInput: string): string | null {
  const trimmed = rawInput.trim();
  if (!trimmed) {
    return null;
  }

  const pathMatch = trimmed.match(/\/import\/([A-Za-z0-9-]+)(?:[/?#]|$)/);
  const candidate = pathMatch?.[1] ?? trimmed;
  return canonicalEpisodeId(candidate);
}
