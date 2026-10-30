import { createServerClient, serializeCookieHeader } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import {
  AUTH_NEXT_COOKIE_NAME,
  buildLoginHref,
  resolveRequestOrigin,
  sanitizeNextPath,
} from "@/lib/auth/redirect";
import type { Database } from "@/lib/supabase/database.types";
import { getSupabasePublicEnv } from "@/lib/supabase/env";

async function startGoogleOAuth(request: Request, rawNext: string | null) {
  const safeNext = sanitizeNextPath(rawNext);
  const origin = resolveRequestOrigin(request);
  const cookieStore = await cookies();
  const responseHeaders = new Headers();
  const { url, publishableKey } = getSupabasePublicEnv();

  const supabase = createServerClient<Database>(url, publishableKey, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet, cacheHeaders) {
        cookiesToSet.forEach(({ name, value, options }) => {
          responseHeaders.append(
            "Set-Cookie",
            serializeCookieHeader(name, value, options)
          );
        });
        Object.entries(cacheHeaders).forEach(([key, value]) => {
          responseHeaders.set(key, value);
        });
      },
    },
  });

  // Persist validated return path in a short-lived HttpOnly cookie so exact-match
  // `/auth/callback` allowlists on Supabase preserve `/import/[episodeId]` reliably.
  responseHeaders.append(
    "Set-Cookie",
    serializeCookieHeader(AUTH_NEXT_COOKIE_NAME, safeNext, {
      path: "/",
      httpOnly: true,
      sameSite: "lax",
      secure: process.env.NODE_ENV === "production",
      maxAge: 600,
    })
  );

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: `${origin}/auth/callback`,
    },
  });

  if (error || !data.url) {
    const fallbackLogin = new URL(buildLoginHref(safeNext), origin);
    fallbackLogin.searchParams.set("error", "oauth_init_failed");
    return NextResponse.redirect(fallbackLogin, { status: 303 });
  }

  responseHeaders.set("Location", data.url);
  return new Response(null, {
    status: 303,
    headers: responseHeaders,
  });
}

export async function POST(request: Request) {
  let rawNext: string | null = null;
  try {
    const formData = await request.formData();
    const field = formData.get("next");
    if (typeof field === "string") {
      rawNext = field;
    }
  } catch {
    // Ignore malformed body and fall back to query param
  }

  if (!rawNext) {
    rawNext = new URL(request.url).searchParams.get("next");
  }

  return startGoogleOAuth(request, rawNext);
}

export async function GET(request: Request) {
  const rawNext = new URL(request.url).searchParams.get("next");
  return startGoogleOAuth(request, rawNext);
}
