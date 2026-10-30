import type { MetadataRoute } from "next";
import { getMetadataBase } from "@/lib/site";

export default function robots(): MetadataRoute.Robots {
  const origin = getMetadataBase().origin;

  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/login", "/auth", "/settings", "/review", "/library"],
    },
    sitemap: `${origin}/sitemap.xml`,
  };
}
