import { NextResponse } from "next/server";
import { resolveRequestOrigin } from "@/lib/auth/redirect";
import { createClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  const supabase = await createClient();
  await supabase.auth.signOut();
  const origin = resolveRequestOrigin(request);
  return NextResponse.redirect(`${origin}/login`, { status: 303 });
}
