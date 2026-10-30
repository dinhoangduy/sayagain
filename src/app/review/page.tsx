import { Suspense } from "react";
import type { Metadata } from "next";
import { ReviewScreen } from "@/components/review/ReviewScreen";

export const metadata: Metadata = {
  title: "Review Due Cards",
};

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
