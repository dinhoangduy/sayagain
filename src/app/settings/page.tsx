import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { LogOut, User } from "lucide-react";
import { SettingsControls } from "@/components/settings/SettingsControls";
import { buildLoginHref } from "@/lib/auth/redirect";
import { pageSeo } from "@/lib/site";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = pageSeo({
  title: "Settings",
  description: "Manage your SayAgain account, study data, and app install options.",
  index: false,
});

export default async function SettingsPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect(buildLoginHref("/settings"));
  }

  const { data: settingsRow } = await supabase
    .from("user_settings")
    .select("timezone")
    .eq("user_id", user.id)
    .maybeSingle();

  const initialTimezone = settingsRow?.timezone ?? "UTC";
  const email = user.email ?? "Signed-in user";

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-[#132019]">
          Settings
        </h1>
        <p className="mt-0.5 text-xs text-[#52635a] sm:text-sm">
          Account, time zone, home-screen installation, and study data.
        </p>
      </div>

      {/* Account Card */}
      <section className="rounded-2xl border border-[#dce7e0] bg-white p-5 shadow-xs sm:p-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex min-w-0 items-center gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-[#eaf5ee] text-[#146c43]">
              <User className="h-5 w-5" aria-hidden="true" />
            </div>
            <div className="min-w-0">
              <p className="truncate text-sm font-bold text-[#132019]">
                {email}
              </p>
              <p className="text-xs text-[#52635a]">Google Account</p>
            </div>
          </div>

          <form action="/auth/signout" method="POST">
            <button
              type="submit"
              className="inline-flex min-h-[42px] w-full cursor-pointer items-center justify-center gap-1.5 rounded-xl border border-[#dce7e0] bg-white px-4 py-2 text-xs font-semibold text-[#132019] transition hover:bg-[#f7faf8] sm:w-auto"
            >
              <LogOut className="h-3.5 w-3.5" aria-hidden="true" />
              <span>Sign Out</span>
            </button>
          </form>
        </div>
      </section>

      <SettingsControls
        userId={user.id}
        userEmail={email}
        initialTimezone={initialTimezone}
      />
    </div>
  );
}
