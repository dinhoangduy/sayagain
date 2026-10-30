import type { Metadata } from "next";
import { LibraryScreen } from "@/components/library/LibraryScreen";
import { pageSeo } from "@/lib/site";

export const metadata: Metadata = pageSeo({
  title: "My Library",
  description: "Browse the English speaking decks you have imported into SayAgain.",
  index: false,
});

export default function LibraryPage() {
  return <LibraryScreen />;
}
