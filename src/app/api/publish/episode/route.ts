import { NextResponse } from "next/server";
import { episodeExportSchema } from "@/lib/episodes/schema";
import { publishEpisodeDeck } from "@/lib/episodes/publishDeck";
import {
  publishSecretsMatch,
  readBearerToken,
} from "@/lib/episodes/publishAuth";
import { createAdminClient, requireSupabaseUrl } from "@/lib/supabase/admin";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Publishes one episode deck so learners can import it from `/import/{id}`.
 * Callers must send `Authorization: Bearer $SAYAGAIN_PUBLISH_SECRET`.
 * @param request - JSON body matching the episode export schema.
 * @returns The import path, or an error status when auth or validation fails.
 */
export async function POST(request: Request) {
  const expected = process.env.SAYAGAIN_PUBLISH_SECRET;
  const provided = readBearerToken(request.headers.get("authorization"));
  if (!expected?.trim()) {
    return NextResponse.json(
      { error: "Publishing is not configured. Set SAYAGAIN_PUBLISH_SECRET." },
      { status: 503 }
    );
  }
  if (!publishSecretsMatch(provided, expected)) {
    return NextResponse.json(
      { error: "Invalid publish secret." },
      { status: 401 }
    );
  }

  let payload: unknown;
  try {
    payload = await request.json();
  } catch {
    return NextResponse.json(
      { error: "Request body must be JSON." },
      { status: 400 }
    );
  }

  const validated = episodeExportSchema.safeParse(payload);
  if (!validated.success) {
    return NextResponse.json(
      { error: "Invalid episode payload.", issues: validated.error.issues },
      { status: 400 }
    );
  }

  if (validated.data.status !== "published") {
    return NextResponse.json(
      { error: "Only status 'published' can be imported by learners." },
      { status: 400 }
    );
  }

  try {
    const result = await publishEpisodeDeck(
      createAdminClient(),
      requireSupabaseUrl(),
      validated.data
    );
    return NextResponse.json(result);
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Could not publish episode.";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
