import Link from "next/link";
import { SearchX } from "lucide-react";
import { EpisodeLookupForm } from "@/components/import/EpisodeLookupForm";
import { SAMPLE_EPISODE_ID } from "@/lib/episodes/sampleDeck";

export default function EpisodeNotFound() {
  return (
    <div className="space-y-5 py-4">
      <div className="rounded-2xl border border-[#dce7e0] bg-white p-6 text-center shadow-xs">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#eaf5ee] text-[#146c43]">
          <SearchX className="h-6 w-6" aria-hidden="true" />
        </div>
        <h1 className="mt-4 text-xl font-bold tracking-tight text-[#132019]">
          Episode deck not found
        </h1>
        <p className="mx-auto mt-1.5 max-w-sm text-sm leading-relaxed text-[#52635a]">
          This episode link may have a typo, or the deck hasn’t been published
          yet. Check the episode ID and try again.
        </p>

        <div className="mt-5 text-left">
          <EpisodeLookupForm compact />
        </div>

        <div className="mt-5 flex flex-wrap items-center justify-center gap-3 border-t border-[#edf2ef] pt-4 text-xs font-semibold">
          <Link
            href={`/import/${SAMPLE_EPISODE_ID}`}
            className="text-[#146c43] hover:underline"
          >
            Try SCN-021 You forgot their name again
          </Link>
          <span className="text-[#cddcd3]">•</span>
          <Link href="/" className="text-[#52635a] hover:text-[#132019]">
            Back to Home
          </Link>
        </div>
      </div>
    </div>
  );
}
