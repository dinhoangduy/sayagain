import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database, Json } from "@/lib/supabase/database.types";
import {
  type EpisodeExport,
  type StoredCardDraft,
  toStoredCardDraft,
} from "./schema";

const IMAGE_EXTENSION: Record<
  NonNullable<StoredCardDraft["image"]>["contentType"],
  string
> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

export type PublishEpisodeResult = {
  episodeId: string;
  title: string;
  cardCount: number;
  importPath: string;
};

/**
 * Decodes a card image and rejects payloads that are not a real image under 5 MB.
 * @param image - Base64 upload from the publish payload.
 * @returns Raw image bytes.
 */
function decodeCardImage(image: NonNullable<StoredCardDraft["image"]>): Uint8Array {
  const cleaned = image.dataBase64.replace(/\s/g, "");
  if (!/^[A-Za-z0-9+/]+={0,2}$/.test(cleaned)) {
    throw new Error("Card image is not valid base64.");
  }

  const bytes = Buffer.from(cleaned, "base64");
  if (bytes.length < 32 || bytes.length > 5 * 1024 * 1024) {
    throw new Error("Card image must be between 32 bytes and 5 MB.");
  }

  return new Uint8Array(bytes);
}

/**
 * Uploads a card picture to the public card-images bucket.
 * @param supabase - Service-role client.
 * @param supabaseUrl - Project URL used to build the public object URL.
 * @param episodeId - Deck id, used as the storage folder.
 * @param draft - Card that includes an image upload.
 * @returns Public https URL for the stored image.
 */
async function uploadCardImage(
  supabase: SupabaseClient<Database>,
  supabaseUrl: string,
  episodeId: string,
  draft: StoredCardDraft
): Promise<string> {
  if (!draft.image) {
    throw new Error("Card image upload is missing.");
  }

  const extension = IMAGE_EXTENSION[draft.image.contentType];
  const objectPath = `${episodeId}/${draft.id}.${extension}`;
  const bytes = decodeCardImage(draft.image);
  const { error } = await supabase.storage.from("card-images").upload(
    objectPath,
    bytes,
    {
      contentType: draft.image.contentType,
      upsert: true,
      cacheControl: "31536000",
    }
  );

  if (error) {
    throw new Error(
      `Could not store the card image. Apply supabase/migrations/20261030120000_card_framework.sql so the card-images bucket exists. ${error.message}`
    );
  }

  return `${supabaseUrl}/storage/v1/object/public/card-images/${objectPath}`;
}

/**
 * Upserts one episode and its cards so `/import/{episodeId}` can load them.
 * An image upload replaces `imageUrl`. Existing card ids keep learner progress.
 * @param supabase - Service-role client.
 * @param supabaseUrl - Project URL used for public image links.
 * @param deck - Validated episode export.
 * @returns Ids and the import path learners open from the video description.
 */
export async function publishEpisodeDeck(
  supabase: SupabaseClient<Database>,
  supabaseUrl: string,
  deck: EpisodeExport
): Promise<PublishEpisodeResult> {
  const { error: episodeError } = await supabase.from("episodes").upsert(
    {
      id: deck.episodeId,
      title: deck.title,
      topic: deck.topic,
      description: deck.description,
      language: deck.language,
      source_url: deck.sourceUrl ?? null,
      status: deck.status,
      published_at:
        deck.status === "published" ? new Date().toISOString() : null,
    },
    { onConflict: "id" }
  );

  if (episodeError) {
    throw new Error(`Failed to upsert episode: ${episodeError.message}`);
  }

  const drafts = deck.cards.map((card) => toStoredCardDraft(card));
  const cardRows = [];

  for (const [index, draft] of drafts.entries()) {
    const imageUrl = draft.image
      ? await uploadCardImage(supabase, supabaseUrl, deck.episodeId, draft)
      : draft.imageUrl;

    cardRows.push({
      id: draft.id,
      episode_id: deck.episodeId,
      sort_order: index + 1,
      level: draft.level,
      context: draft.context,
      question: draft.question,
      task: draft.task,
      answer: draft.answer,
      audio_url: draft.audioUrl,
      image_url: imageUrl,
      framework: draft.framework as Json,
      content_version: draft.contentVersion,
    });
  }

  const { error: cardsError } = await supabase
    .from("cards")
    .upsert(cardRows, { onConflict: "id" });

  if (cardsError) {
    throw new Error(`Failed to upsert cards: ${cardsError.message}`);
  }

  return {
    episodeId: deck.episodeId,
    title: deck.title,
    cardCount: cardRows.length,
    importPath: `/import/${deck.episodeId}`,
  };
}
