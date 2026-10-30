import fs from "node:fs/promises";
import path from "node:path";
import { createClient } from "@supabase/supabase-js";
import { episodeExportSchema } from "../src/lib/episodes/schema";
import type { Database } from "../src/lib/supabase/database.types";

async function main() {
  const args = process.argv.slice(2);
  const allowDraft = args.includes("--allow-draft");
  const fileArg = args.find((arg) => !arg.startsWith("--"));

  if (!fileArg) {
    console.error(
      "Usage: pnpm episode:publish <path/to/episode.cards.json> [--allow-draft]"
    );
    process.exit(1);
  }

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL?.trim();
  const adminKey = (
    process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY
  )?.trim();

  if (!supabaseUrl || !adminKey) {
    console.error(
      "Missing SUPABASE_SECRET_KEY (or SUPABASE_SERVICE_ROLE_KEY) and NEXT_PUBLIC_SUPABASE_URL in environment."
    );
    process.exit(1);
  }

  const resolvedPath = path.resolve(process.cwd(), fileArg);
  const rawJson = await fs.readFile(resolvedPath, "utf8");
  const parsedJson = JSON.parse(rawJson) as unknown;

  const validated = episodeExportSchema.safeParse(parsedJson);
  if (!validated.success) {
    console.error("Episode JSON validation failed:");
    console.error(validated.error.format());
    process.exit(1);
  }

  const deck = validated.data;
  if (deck.status !== "published" && !allowDraft) {
    console.error(
      `Refusing to import episode '${deck.episodeId}' with status='${deck.status}'. Set status to 'published' or pass --allow-draft.`
    );
    process.exit(1);
  }

  const supabase = createClient<Database>(supabaseUrl, adminKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

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
    console.error("Failed to upsert episode:", episodeError.message);
    process.exit(1);
  }

  const cardRows = deck.cards.map((card, index) => ({
    id: card.cardId,
    episode_id: deck.episodeId,
    sort_order: index + 1,
    level: card.level,
    context: card.context,
    question: card.prompt,
    task: card.task,
    answer: card.answer,
    audio_url: card.audioUrl ?? null,
    content_version: card.contentVersion,
  }));

  const { error: cardsError } = await supabase
    .from("cards")
    .upsert(cardRows, { onConflict: "id" });

  if (cardsError) {
    console.error("Failed to upsert cards:", cardsError.message);
    process.exit(1);
  }

  console.log(
    `Published episode '${deck.episodeId}' (${deck.title}) with ${cardRows.length} cards.`
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
