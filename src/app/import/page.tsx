import type { Metadata } from "next";
import { EpisodeLookupForm } from "@/components/import/EpisodeLookupForm";

export const metadata: Metadata = {
  title: "Import Episode Deck",
};

export default function ImportIndexPage() {
  return (
    <div className="space-y-6">
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <h1 className="text-xl font-bold tracking-tight text-[#132019] sm:text-2xl">
          Import Episode Flashcards
        </h1>
        <p className="mt-1.5 text-sm leading-relaxed text-[#52635a]">
          Paste the import link from a video to preview its speaking card and
          add it to your review queue.
        </p>

        <div className="mt-4">
          <EpisodeLookupForm />
        </div>
      </section>
    </div>
  );
}
