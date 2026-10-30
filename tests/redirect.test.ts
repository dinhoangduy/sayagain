import { describe, expect, it } from "vitest";
import { buildLoginHref, sanitizeNextPath } from "@/lib/auth/redirect";

describe("sanitizeNextPath & buildLoginHref", () => {
  it("preserves safe local import and review deep links", () => {
    expect(sanitizeNextPath("/import/episode-001")).toBe("/import/episode-001");
    expect(sanitizeNextPath("/review?episode=episode-001")).toBe(
      "/review?episode=episode-001"
    );
    expect(sanitizeNextPath("/library")).toBe("/library");
    expect(buildLoginHref("/import/episode-001")).toBe(
      "/login?next=%2Fimport%2Fepisode-001"
    );
  });

  it("blocks external URLs, protocol-relative URLs, backslashes, and schemes", () => {
    expect(sanitizeNextPath("https://evil.example/phish")).toBe("/");
    expect(sanitizeNextPath("http://evil.example")).toBe("/");
    expect(sanitizeNextPath("//evil.example/import/episode-001")).toBe("/");
    expect(sanitizeNextPath("/\\evil.example")).toBe("/");
    expect(sanitizeNextPath("javascript:alert(1)")).toBe("/");
    expect(sanitizeNextPath("/import/episode-001\r\nSet-Cookie: bad=1")).toBe(
      "/"
    );
  });

  it("prevents redirect loops back to /login or /auth/*", () => {
    expect(sanitizeNextPath("/login")).toBe("/");
    expect(sanitizeNextPath("/login?next=/import/episode-001")).toBe("/");
    expect(sanitizeNextPath("/auth/callback")).toBe("/");
    expect(sanitizeNextPath("/auth/google")).toBe("/");
    expect(buildLoginHref("/")).toBe("/login");
  });
});
