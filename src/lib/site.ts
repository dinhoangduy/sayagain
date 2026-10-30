import type { Metadata } from "next";

const LOCAL_SITE_ORIGIN = "http://localhost:5001";

export const SITE_NAME = "SayAgain";

export const SITE_TITLE = "SayAgain — English Speaking Flashcards";

export const SITE_DESCRIPTION =
  "Practice speaking English aloud with one-minute episode flashcards and spaced repetition. Import a deck, then review due cards out loud.";

export const SITE_OG_IMAGE_PATH = "/og.png";

export const SITE_OG_IMAGE = {
  url: SITE_OG_IMAGE_PATH,
  width: 1200,
  height: 630,
  alt: "SayAgain logo with English One Minute — speak English aloud using one-minute episode flashcards",
} as const;

/**
 * Resolves the public origin used for canonical URLs, Open Graph images, and the sitemap.
 * @returns Absolute site origin. Prefers NEXT_PUBLIC_SITE_URL, then the Vercel production host.
 */
export function getMetadataBase(): URL {
  const configured = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  if (configured) {
    try {
      return new URL(configured);
    } catch {
      return new URL(LOCAL_SITE_ORIGIN);
    }
  }

  const productionHost = process.env.VERCEL_PROJECT_PRODUCTION_URL?.trim();
  if (productionHost) {
    return new URL(`https://${productionHost.replace(/^https?:\/\//, "")}`);
  }

  const deploymentHost = process.env.VERCEL_URL?.trim();
  if (deploymentHost) {
    return new URL(`https://${deploymentHost.replace(/^https?:\/\//, "")}`);
  }

  return new URL(LOCAL_SITE_ORIGIN);
}

interface PageSeoInput {
  title: string;
  description: string;
  canonical?: string;
  index?: boolean;
}

/**
 * Builds page metadata so the document title, Open Graph, and Twitter cards stay in sync.
 * @param input - Page title, description, optional canonical path, and whether the page should be indexed.
 * @returns Next.js metadata for that route. Private pages set `index` to false.
 */
export function pageSeo(input: PageSeoInput): Metadata {
  const socialTitle = `${input.title} · ${SITE_NAME}`;
  const metadata: Metadata = {
    title: input.title,
    description: input.description,
    openGraph: {
      title: socialTitle,
      description: input.description,
      siteName: SITE_NAME,
      type: "website",
      locale: "en_US",
      images: [SITE_OG_IMAGE],
    },
    twitter: {
      card: "summary_large_image",
      title: socialTitle,
      description: input.description,
      images: [SITE_OG_IMAGE.url],
    },
  };

  if (input.canonical) {
    metadata.alternates = { canonical: input.canonical };
  }

  if (input.index === false) {
    metadata.robots = { index: false, follow: false };
  }

  return metadata;
}
