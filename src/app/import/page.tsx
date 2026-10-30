import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, Sparkles } from "lucide-react";
import { EpisodeLookupForm } from "@/components/import/EpisodeLookupForm";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "Import Episode Deck",
};

export default async function ImportIndexPage() {
  const supabase = await createClient();

  const { data: episodes } = await supabase
    .from("episodes")
    .select("id, title, topic, description, language")
    .eq("status", "published")
    .order("published_at", { ascending: false })
    .limit(20);

  return (
    <div className="space-y-6">
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <h1 className="text-xl font-bold tracking-tight text-[#132019] sm:text-2xl">
          Import Episode Flashcards
        </h1>
        <p className="mt-1.5 text-sm leading-relaxed text-[#52635a]">
          Enter an episode ID from an English Speaking Challenge video to
          preview its speaking prompts and add them to your review queue.
        </p>

        <div className="mt-4">
          <EpisodeLookupForm />
        </div>
      </section>

      <section className="space-y-3">
        <div className="flex items-center justify-between px-1">
          <h2 className="text-sm font-semibold text-[#132019]">
            Available Episode Decks
          </h2>
          <span className="inline-flex items-center gap-1 text-xs font-medium text-[#146c43]">
            <Sparkles className="h-3.5 w-3.5" aria-hidden="true" />
            <span>Published</span>
          </span>
        </div>

        {episodes && episodes.length > 0 ? (
          <div className="space-y-2.5">
            {episodes.map((ep) => (
              <Link
                key={ep.id}
                href={`/import/${ep.id}`}
                className="flex items-center justify-between gap-3 rounded-2xl border border-[#dce7e0] bg-white p-4 transition hover:border-[#9fd0b2] hover:bg-[#fbfdfc]"
              >
                <div className="min-w-0 space-y-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="rounded-md bg-[#eaf5ee] px-2 py-0.5 font-mono text-[11px] font-semibold text-[#146c43]">
                      {ep.id}
                    </span>
                    {ep.topic && (
                      <span className="truncate text-xs text-[#52635a]">
                        {ep.topic}
                      </span>
                    )}
                  </div>
                  <p className="text-base font-semibold text-[#132019]">
                    {ep.title}
                  </p>
                  {ep.description && (
                    <p className="line-clamp-2 text-xs leading-relaxed text-[#52635a]">
                      {ep.description}
                    </p>
                  )}
                </div>
                <ArrowRight
                  className="h-4 w-4 shrink-0 text-[#146c43]"
                  aria-hidden="true"
                />
              </Link>
            ))}
          </div>
        ) : (
          <div className="rounded-2xl border border-[#dce7e0] bg-white p-5 text-sm text-[#52635a]">
            No published episodes found yet.
          </div>
        )}
      </section>
    </div>
  );
}
