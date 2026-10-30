import fs from "node:fs/promises";
import path from "node:path";
import { publishEpisodeDeck } from "../src/lib/episodes/publishDeck";
import { episodeExportSchema } from "../src/lib/episodes/schema";
import { createAdminClient, requireSupabaseUrl } from "../src/lib/supabase/admin";

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

  try {
    const result = await publishEpisodeDeck(
      createAdminClient(),
      requireSupabaseUrl(),
      deck
    );
    console.log(
      `Published episode '${result.episodeId}' (${result.title}) with ${result.cardCount} cards.`
    );
    console.log(`Import path: ${result.importPath}`);
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
