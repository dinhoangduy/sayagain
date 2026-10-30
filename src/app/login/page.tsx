import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { AlertCircle, ArrowRight, ShieldCheck } from "lucide-react";
import { sanitizeNextPath } from "@/lib/auth/redirect";
import { pageSeo } from "@/lib/site";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = pageSeo({
  title: "Sign In",
  description: "Sign in to SayAgain to save episode flashcards and review them across devices.",
  index: false,
});

const ERROR_MESSAGES: Record<string, string> = {
  oauth_init_failed:
    "Could not start Google sign-in. Verify Google OAuth is enabled in your Supabase dashboard.",
  oauth_denied: "Google sign-in was cancelled before completing.",
  auth_callback_failed:
    "Your sign-in session could not be verified. Please try signing in again.",
};

interface LoginPageProps {
  searchParams: Promise<{
    next?: string;
    error?: string;
  }>;
}

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;
  const safeNext = sanitizeNextPath(params.next);
  const errorMessage = params.error
    ? ERROR_MESSAGES[params.error] ?? "Sign-in failed. Please try again."
    : null;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (user) {
    redirect(safeNext);
  }

  const importMatch = safeNext.match(/^\/import\/([a-z0-9-]+)$/);
  const returningEpisodeId = importMatch?.[1] ?? null;

  return (
    <div className="mx-auto max-w-md py-4 sm:py-8">
      <div className="rounded-2xl border border-[#dce7e0] bg-white p-6 shadow-xs sm:p-7">
        <div className="mb-5">
          <span className="inline-flex items-center rounded-full bg-[#eaf5ee] px-3 py-1 text-xs font-semibold text-[#146c43]">
            Free Speaking Practice
          </span>
          <h1 className="mt-3 text-2xl font-bold tracking-tight text-[#132019]">
            Sign in to SayAgain
          </h1>
          <p className="mt-1.5 text-sm leading-relaxed text-[#52635a]">
            Save your imported episode flashcards and review due cards across
            all your devices with spaced repetition.
          </p>
        </div>

        {returningEpisodeId && (
          <div className="mb-5 flex items-start gap-2.5 rounded-xl border border-[#c8e3d2] bg-[#f4faf6] p-3.5 text-xs text-[#1d452f]">
            <ArrowRight
              className="mt-0.5 h-4 w-4 shrink-0 text-[#146c43]"
              aria-hidden="true"
            />
            <p className="leading-relaxed">
              After signing in, you’ll return directly to preview and import{" "}
              <strong className="font-semibold">{returningEpisodeId}</strong>.
            </p>
          </div>
        )}

        {errorMessage && (
          <div
            role="alert"
            className="mb-5 flex items-start gap-2.5 rounded-xl border border-[#f2c6c6] bg-[#fff5f5] p-3.5 text-xs text-[#9b2c2c]"
          >
            <AlertCircle
              className="mt-0.5 h-4 w-4 shrink-0"
              aria-hidden="true"
            />
            <p className="leading-relaxed">{errorMessage}</p>
          </div>
        )}

        <form action="/auth/google" method="POST">
          <input type="hidden" name="next" value={safeNext} />
          <button
            type="submit"
            className="flex min-h-[48px] w-full cursor-pointer items-center justify-center gap-3 rounded-xl bg-[#146c43] px-4 py-3 text-sm font-semibold text-white transition hover:bg-[#0f5635] focus:outline-none focus-visible:ring-2 focus-visible:ring-[#146c43] focus-visible:ring-offset-2"
          >
            <svg
              aria-hidden="true"
              viewBox="0 0 24 24"
              className="h-5 w-5 shrink-0 rounded-full bg-white p-0.5"
            >
              <path
                fill="#4285F4"
                d="M23.49 12.27c0-.79-.07-1.54-.19-2.27H12v4.51h6.47c-.29 1.48-1.14 2.73-2.4 3.58v3h3.86c2.26-2.09 3.56-5.17 3.56-8.82z"
              />
              <path
                fill="#34A853"
                d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.86-3c-1.08.72-2.45 1.16-4.07 1.16-3.13 0-5.78-2.11-6.73-4.96H1.29v3.09C3.26 21.3 7.31 24 12 24z"
              />
              <path
                fill="#FBBC05"
                d="M5.27 14.29c-.25-.72-.38-1.49-.38-2.29s.14-1.57.38-2.29V6.62H1.29C.47 8.24 0 10.06 0 12s.47 3.76 1.29 5.38l3.98-3.09z"
              />
              <path
                fill="#EA4335"
                d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.31 0 3.26 2.7 1.29 6.62l3.98 3.09c.95-2.85 3.6-4.96 6.73-4.96z"
              />
            </svg>
            <span>Continue with Google</span>
          </button>
        </form>

        <div className="mt-5 flex items-start gap-2 border-t border-[#edf2ef] pt-4 text-xs text-[#52635a]">
          <ShieldCheck
            className="mt-0.5 h-4 w-4 shrink-0 text-[#146c43]"
            aria-hidden="true"
          />
          <p className="leading-relaxed">
            Privacy: SayAgain only stores your account email and flashcard
            schedule. Your microphone is never recorded or uploaded.
          </p>
        </div>
      </div>

      <div className="mt-4 text-center">
        <Link
          href="/"
          className="text-xs font-medium text-[#52635a] underline-offset-4 hover:text-[#132019] hover:underline"
        >
          Back to Home
        </Link>
      </div>
    </div>
  );
}
