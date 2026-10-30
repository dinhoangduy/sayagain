import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "./database.types";

/**
 * Creates a Supabase client with the service-role key for deck publishing.
 * @returns Admin client that bypasses row level security.
 * @throws If the project URL or secret key is missing.
 */
export function createAdminClient(): SupabaseClient<Database> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL?.trim();
  const adminKey = (
    process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY
  )?.trim();

  if (!url || !adminKey) {
    throw new Error(
      "Missing SUPABASE_SECRET_KEY (or SUPABASE_SERVICE_ROLE_KEY) and NEXT_PUBLIC_SUPABASE_URL."
    );
  }

  return createClient<Database>(url, adminKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

/**
 * Reads the public project URL used to build storage object links.
 * @returns Supabase project URL without a trailing slash.
 * @throws If NEXT_PUBLIC_SUPABASE_URL is missing.
 */
export function requireSupabaseUrl(): string {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL?.trim();
  if (!url) {
    throw new Error("Missing NEXT_PUBLIC_SUPABASE_URL.");
  }
  return url.replace(/\/$/, "");
}
