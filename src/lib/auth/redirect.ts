export const AUTH_NEXT_COOKIE_NAME = "sayagain_auth_next";

const DUMMY_ORIGIN = "http://sayagain.local";
const MAX_REDIRECT_LENGTH = 256;

const DISALLOWED_PREFIXES = ["/login", "/auth"];

/**
 * Validates and normalizes an untrusted `next` return URL parameter so redirects
 * stay strictly inside local SayAgain application routes (prevents open redirects).
 */
export function sanitizeNextPath(raw: string | null | undefined): string {
  if (!raw || typeof raw !== "string") {
    return "/";
  }

  const trimmed = raw.trim();
  if (
    trimmed.length === 0 ||
    trimmed.length > MAX_REDIRECT_LENGTH ||
    !trimmed.startsWith("/") ||
    trimmed.startsWith("//") ||
    trimmed.startsWith("/\\") ||
    /[\u0000-\u001F\u007F\\]/.test(trimmed)
  ) {
    return "/";
  }

  try {
    const parsed = new URL(trimmed, DUMMY_ORIGIN);
    if (parsed.origin !== DUMMY_ORIGIN) {
      return "/";
    }

    const normalizedPath = parsed.pathname;
    for (const prefix of DISALLOWED_PREFIXES) {
      if (
        normalizedPath === prefix ||
        normalizedPath.startsWith(`${prefix}/`)
      ) {
        return "/";
      }
    }

    return `${normalizedPath}${parsed.search}`;
  } catch {
    return "/";
  }
}

export function buildLoginHref(nextPath: string): string {
  const safeNext = sanitizeNextPath(nextPath);
  if (safeNext === "/") {
    return "/login";
  }
  return `/login?next=${encodeURIComponent(safeNext)}`;
}

export function resolveRequestOrigin(request: Request): string {
  const configuredSiteUrl = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  if (configuredSiteUrl) {
    try {
      return new URL(configuredSiteUrl).origin;
    } catch {
      // Fall back to request headers / URL
    }
  }

  const { origin } = new URL(request.url);
  if (process.env.NODE_ENV === "development") {
    return origin;
  }

  const forwardedHost = request.headers
    .get("x-forwarded-host")
    ?.split(",")[0]
    ?.trim();
  const forwardedProto =
    request.headers.get("x-forwarded-proto")?.split(",")[0]?.trim() || "https";

  if (forwardedHost) {
    return `${forwardedProto}://${forwardedHost}`;
  }

  return origin;
}
