"use client";

import { useAccountProfile } from "@/components/use-account-profile";
import { useCourseCertificates } from "@/components/use-course-certificates";

function DetailCard(props: { label: string; value: string }) {
  return (
    <div className="rounded-[1.4rem] border border-white/10 bg-white/[0.045] p-5">
      <p className="text-sm uppercase tracking-[0.24em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-3 text-xl font-semibold text-white">{props.value}</p>
    </div>
  );
}

function EmptyCertificates() {
  return (
    <div className="rounded-[1.4rem] border border-dashed border-white/10 bg-black/20 p-5 text-sm leading-7 text-stone-300">
      No certificates yet. Finish a full course level and clear its final exam to unlock one here.
    </div>
  );
}

function CertificateCard(props: {
  issuedAt: string;
  levelLabel: string;
  onDownload: () => void;
  summary: string;
  title: string;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.045] p-5">
      <p className="text-sm uppercase tracking-[0.28em] text-amber-100">
        {props.levelLabel}
      </p>
      <h3 className="mt-3 text-2xl font-semibold text-white">{props.title}</h3>
      <p className="mt-3 text-sm leading-7 text-stone-300">{props.summary}</p>
      <p className="mt-4 text-xs uppercase tracking-[0.2em] text-stone-500">
        Issued {new Date(props.issuedAt).toLocaleDateString("en-IN")}
      </p>
      <button
        type="button"
        onClick={props.onDownload}
        className="mt-5 rounded-full border border-amber-300/20 bg-amber-300/10 px-4 py-2 text-sm font-medium text-amber-100 transition hover:bg-amber-300/18"
      >
        Download certificate
      </button>
    </div>
  );
}

export function ProfileSummary() {
  const { profile } = useAccountProfile();
  const certificates = useCourseCertificates();

  return (
    <section className="space-y-8">
      <section className="rounded-[2rem] border border-white/10 bg-[linear-gradient(135deg,rgba(247,200,116,0.14),rgba(255,255,255,0.03))] p-7 shadow-[0_30px_90px_rgba(0,0,0,0.2)]">
        <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
          Profile
        </p>
        <h1 className="mt-4 text-4xl font-semibold tracking-[-0.04em] text-white">
          Personal details
        </h1>
        <p className="mt-4 max-w-2xl text-base leading-8 text-stone-200">
          Your identity, learning provider, and earned course certificates live here in one reliable place.
        </p>
        <div className="mt-8 grid gap-4 lg:grid-cols-3">
          <DetailCard label="Full name" value={profile.name} />
          <DetailCard label="Email" value={profile.email} />
          <DetailCard label="Provider" value={profile.provider} />
        </div>
      </section>
      <section className="rounded-[2rem] border border-white/10 bg-white/[0.045] p-7">
        <p className="text-sm uppercase tracking-[0.35em] text-amber-100">
          Certificates
        </p>
        <h2 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white">
          Earned course certificates
        </h2>
        <p className="mt-4 max-w-2xl text-base leading-8 text-stone-300">
          Every completed level certificate is stored on this profile and can be downloaded anytime.
        </p>
        <div className="mt-8 grid gap-4 lg:grid-cols-2">
          {certificates.certificates.length > 0
            ? certificates.certificates.map((certificate) => (
                <CertificateCard
                  key={certificate.id}
                  title={certificate.title}
                  summary={certificate.summary}
                  levelLabel={`${certificate.courseName} · ${certificate.officialLabel}`}
                  issuedAt={certificate.issuedAt}
                  onDownload={() => certificates.download(certificate)}
                />
              ))
            : <EmptyCertificates />}
        </div>
      </section>
    </section>
  );
}
