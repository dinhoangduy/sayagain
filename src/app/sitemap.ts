import type { MetadataRoute } from "next";
import { getMetadataBase } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  const origin = getMetadataBase().origin;
  const lastModified = new Date();

  return [
    {
      url: origin,
      lastModified,
      changeFrequency: "weekly",
      priority: 1,
    },
    {
      url: `${origin}/import`,
      lastModified,
      changeFrequency: "weekly",
      priority: 0.8,
    },
  ];
}
