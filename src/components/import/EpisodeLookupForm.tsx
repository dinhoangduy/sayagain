"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, Search } from "lucide-react";
import { extractEpisodeIdFromInput } from "@/lib/episodes/schema";

interface EpisodeLookupFormProps {
  compact?: boolean;
  defaultValue?: string;
}

export function EpisodeLookupForm({
  compact = false,
  defaultValue = "",
}: EpisodeLookupFormProps) {
  const router = useRouter();
  const [value, setValue] = useState(defaultValue);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const episodeId = extractEpisodeIdFromInput(value);
    if (!episodeId) {
      setError("Paste a valid import link.");
      return;
    }

    setError(null);
    router.push(`/import/${episodeId}`);
  };

  return (
    <form onSubmit={handleSubmit} className="w-full" noValidate>
      <label htmlFor="episode-id-input" className="sr-only">
        Episode ID or import link
      </label>
      <div className="flex flex-col gap-2 sm:flex-row">
        <div className="relative flex-1">
          <Search
            aria-hidden="true"
            className="pointer-events-none absolute top-1/2 left-3.5 h-4 w-4 -translate-y-1/2 text-[#52635a]"
          />
          <input
            id="episode-id-input"
            type="text"
            value={value}
            onChange={(e) => {
              setValue(e.target.value);
              if (error) setError(null);
            }}
            placeholder="Paste the import link"
            autoCapitalize="none"
            autoCorrect="off"
            spellCheck={false}
            className={`w-full rounded-xl border border-[#cddcd3] bg-white pr-3.5 pl-10 text-sm text-[#132019] placeholder:text-[#788a80] focus:border-[#146c43] focus:outline-none focus-visible:ring-2 focus-visible:ring-[#146c43]/25 ${
              compact ? "min-h-[44px] py-2" : "min-h-[48px] py-2.5"
            }`}
          />
        </div>
        <button
          type="submit"
          className={`inline-flex shrink-0 cursor-pointer items-center justify-center gap-1.5 rounded-xl bg-[#146c43] px-4 font-semibold text-white transition hover:bg-[#0f5635] ${
            compact
              ? "min-h-[44px] py-2 text-xs sm:text-sm"
              : "min-h-[48px] py-2.5 text-sm"
          }`}
        >
          <span>Preview Deck</span>
          <ArrowRight className="h-4 w-4" aria-hidden="true" />
        </button>
      </div>
      {error && (
        <p role="alert" className="mt-2 text-xs font-medium text-[#9b2c2c]">
          {error}
        </p>
      )}
    </form>
  );
}
