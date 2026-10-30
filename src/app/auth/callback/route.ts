import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import {
  AUTH_NEXT_COOKIE_NAME,
  buildLoginHref,
  resolveRequestOrigin,
  sanitizeNextPath,
} from "@/lib/auth/redirect";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const requestUrl = new URL(request.url);
  const code = requestUrl.searchParams.get("code");
  const oauthError = requestUrl.searchParams.get("error");
  const cookieStore = await cookies();

  const storedNext = cookieStore.get(AUTH_NEXT_COOKIE_NAME)?.value ?? null;
  const queryNext = requestUrl.searchParams.get("next");
  const safeNext = sanitizeNextPath(queryNext ?? storedNext);
  const origin = resolveRequestOrigin(request);

  const clearNextCookie = (response: NextResponse) => {
    response.cookies.set(AUTH_NEXT_COOKIE_NAME, "", {
      path: "/",
      httpOnly: true,
      sameSite: "lax",
      maxAge: 0,
    });
    return response;
  };

  if (oauthError) {
    const loginUrl = new URL(buildLoginHref(safeNext), origin);
    loginUrl.searchParams.set("error", "oauth_denied");
    return clearNextCookie(NextResponse.redirect(loginUrl));
  }

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return clearNextCookie(NextResponse.redirect(`${origin}${safeNext}`));
    }
  }

  const loginUrl = new URL(buildLoginHref(safeNext), origin);
  loginUrl.searchParams.set("error", "auth_callback_failed");
  return clearNextCookie(NextResponse.redirect(loginUrl));
}
