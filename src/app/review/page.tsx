import { Suspense } from "react";
import type { Metadata } from "next";
import { ReviewScreen } from "@/components/review/ReviewScreen";
import { pageSeo } from "@/lib/site";

export const metadata: Metadata = pageSeo({
  title: "Review Due Cards",
  description: "Speak your due English flashcards aloud and rate how well you remembered them.",
  index: false,
});

export default function ReviewPage() {
  return (
    <Suspense
      fallback={
        <div className="h-48 animate-pulse rounded-2xl border border-[#dce7e0] bg-white shadow-xs" />
      }
    >
      <ReviewScreen />
    </Suspense>
  );
}
