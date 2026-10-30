import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { AppHeader, MobileBottomNav } from "@/components/layout/AppHeader";
import { InstallBanner } from "@/components/pwa/InstallBanner";
import { ServiceWorkerRegistrar } from "@/components/pwa/ServiceWorkerRegistrar";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: {
    default: "SayAgain — English Speaking Flashcards",
    template: "%s · SayAgain",
  },
  description:
    "Import episode speaking flashcards and practice daily aloud with FSRS spaced repetition.",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "SayAgain",
  },
  icons: {
    icon: [
      { url: "/icons/icon-192.png", sizes: "192x192", type: "image/png" },
      { url: "/icons/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [
      {
        url: "/icons/apple-touch-icon.png",
        sizes: "180x180",
        type: "image/png",
      },
    ],
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
  themeColor: "#146C43",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="flex min-h-dvh flex-col bg-[#f7faf8] text-[#132019]">
        <ServiceWorkerRegistrar />
        <InstallBanner />
        <AppHeader />
        <main className="mx-auto w-full max-w-xl flex-1 px-4 pt-5 pb-24 sm:pb-12">
          {children}
        </main>
        <MobileBottomNav />
      </body>
    </html>
  );
}
