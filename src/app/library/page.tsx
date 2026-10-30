import type { Metadata } from "next";
import { LibraryScreen } from "@/components/library/LibraryScreen";

export const metadata: Metadata = {
  title: "My Library",
};

export default function LibraryPage() {
  return <LibraryScreen />;
}
