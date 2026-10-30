import { describe, expect, it } from "vitest";
import {
  publishSecretsMatch,
  readBearerToken,
} from "@/lib/episodes/publishAuth";

describe("publish auth", () => {
  it("accepts only an exact bearer secret", () => {
    expect(publishSecretsMatch("local-secret", "local-secret")).toBe(true);
    expect(publishSecretsMatch("local-secret", "other-secret")).toBe(false);
    expect(publishSecretsMatch(null, "local-secret")).toBe(false);
    expect(publishSecretsMatch("local-secret", "")).toBe(false);
  });

  it("reads a bearer token and ignores other authorization schemes", () => {
    expect(readBearerToken("Bearer local-secret")).toBe("local-secret");
    expect(readBearerToken("bearer local-secret")).toBe("local-secret");
    expect(readBearerToken("Basic local-secret")).toBeNull();
    expect(readBearerToken(null)).toBeNull();
  });
});
