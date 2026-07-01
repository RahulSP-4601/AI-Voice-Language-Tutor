import {
  FinalCtaSection,
  HeroSection,
  LanguagesSection,
  ProcessSection,
} from "@/components/landing-sections";

export default function Home() {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#080b0d_0%,#0a1110_45%,#071514_100%)] text-stone-100">
      <HeroSection />
      <LanguagesSection />
      <ProcessSection />
      <FinalCtaSection />
    </main>
  );
}
