import { createHash, timingSafeEqual } from "node:crypto";

/**
 * Compares a publish secret without leaking the expected value through timing.
 * @param provided - Secret taken from the request Authorization header.
 * @param expected - SAYAGAIN_PUBLISH_SECRET configured on the server.
 * @returns True only when both values are non-empty and equal.
 */
export function publishSecretsMatch(
  provided: string | null,
  expected: string | null | undefined
): boolean {
  const actual = expected?.trim() ?? "";
  const given = provided?.trim() ?? "";
  if (!actual || !given) {
    return false;
  }

  const actualHash = createHash("sha256").update(actual).digest();
  const givenHash = createHash("sha256").update(given).digest();
  return timingSafeEqual(actualHash, givenHash);
}

/**
 * Reads the bearer token from an Authorization header.
 * @param header - Raw Authorization header, or null when absent.
 * @returns Token after "Bearer ", or null when the header is not a bearer token.
 */
export function readBearerToken(header: string | null): string | null {
  if (!header) {
    return null;
  }
  const match = header.match(/^Bearer\s+(\S+)\s*$/i);
  return match?.[1] ?? null;
}
