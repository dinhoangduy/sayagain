import Link from "next/link";

export default function GlobalNotFound() {
  return (
    <div className="py-8">
      <div className="rounded-2xl border border-[#dce7e0] bg-white p-6 text-center shadow-xs">
        <p className="text-xs font-semibold tracking-wide text-[#146c43] uppercase">
          404
        </p>
        <h1 className="mt-2 text-xl font-bold text-[#132019]">
          Page not found
        </h1>
        <p className="mt-1.5 text-sm text-[#52635a]">
          The page you’re looking for doesn’t exist or may have moved.
        </p>
        <div className="mt-5">
          <Link
            href="/"
            className="inline-flex min-h-[44px] items-center justify-center rounded-xl bg-[#146c43] px-5 py-2.5 text-sm font-semibold text-white hover:bg-[#0f5635]"
          >
            Back to Home
          </Link>
        </div>
      </div>
    </div>
  );
}
