type FeatureCardProps = {
  title: string;
  description: string;
};

export function FeatureCard({ title, description }: FeatureCardProps) {
  return (
    <article className="rounded-3xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm">
      <h2 className="text-xl font-semibold text-white">{title}</h2>
      <p className="mt-3 text-sm leading-7 text-stone-300">{description}</p>
    </article>
  );
}
