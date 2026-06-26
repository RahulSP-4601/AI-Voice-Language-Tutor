import { type CourseLevel, type CourseSlug, type LanguageCourseDefinition } from "@/lib/course-definitions";
import { type StoredCourseProgress } from "@/lib/course-progress";

export type StoredCertificate = {
  courseName: string;
  courseSlug: CourseSlug;
  id: string;
  issuedAt: string;
  learnerName: string;
  levelId: string;
  officialLabel: string;
  productLabel: string;
  summary: string;
  title: string;
};

export type StoredCertificateCatalog = {
  certificates: StoredCertificate[];
  version: 1;
};

const CERTIFICATE_VERSION = 1;

export function createEmptyCertificateCatalog() {
  return {
    certificates: [],
    version: CERTIFICATE_VERSION,
  } satisfies StoredCertificateCatalog;
}

export function getCertificateStorageKey(userId: string) {
  return `ai-voice-tutor.certificates.${userId}`;
}

export function loadCertificateCatalog(storageValue: string | null) {
  const fallback = createEmptyCertificateCatalog();

  if (!storageValue) {
    return fallback;
  }

  try {
    const parsed = JSON.parse(storageValue) as StoredCertificateCatalog;
    if (parsed.version !== CERTIFICATE_VERSION || !Array.isArray(parsed.certificates)) {
      return fallback;
    }

    return parsed;
  } catch {
    return fallback;
  }
}

export function saveCertificateCatalog(
  key: string,
  catalog: StoredCertificateCatalog,
) {
  window.localStorage.setItem(key, JSON.stringify(catalog));
}

export function buildLevelCertificate(input: {
  course: LanguageCourseDefinition;
  learnerName: string;
  level: CourseLevel;
}) {
  return {
    courseName: input.course.name,
    courseSlug: input.course.slug,
    id: `${input.course.slug}-${input.level.id}-certificate`,
    issuedAt: new Date().toISOString(),
    learnerName: input.learnerName,
    levelId: input.level.id,
    officialLabel: input.level.officialLabel,
    productLabel: input.level.productLabel,
    summary: input.level.certificateConfig.summary,
    title: input.level.certificateConfig.title,
  } satisfies StoredCertificate;
}

export function upsertCertificate(
  catalog: StoredCertificateCatalog,
  certificate: StoredCertificate,
) {
  if (
    catalog.certificates.some(
      (item) =>
        item.courseSlug === certificate.courseSlug && item.levelId === certificate.levelId,
    )
  ) {
    return catalog;
  }

  return {
    ...catalog,
    certificates: [...catalog.certificates, certificate].sort((left, right) =>
      right.issuedAt.localeCompare(left.issuedAt),
    ),
  } satisfies StoredCertificateCatalog;
}

export function mergeCertificateCatalogs(
  left: StoredCertificateCatalog,
  right: StoredCertificateCatalog,
) {
  return right.certificates.reduce(
    (current, certificate) => upsertCertificate(current, certificate),
    left,
  );
}

export function hasStoredCertificate(
  catalog: StoredCertificateCatalog,
  slug: CourseSlug,
  levelId: string,
) {
  return catalog.certificates.some(
    (item) => item.courseSlug === slug && item.levelId === levelId,
  );
}

export function isLevelComplete(
  level: CourseLevel,
  progress: StoredCourseProgress,
) {
  return level.modules.every((module) => progress.modules[module.id]?.state === "completed");
}

export function renderCertificateHtml(certificate: StoredCertificate) {
  const issuedDate = new Date(certificate.issuedAt).toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>${certificate.title}</title>
  <style>
    body{margin:0;background:#071011;color:#f5f5f4;font-family:Georgia,serif}
    main{max-width:900px;margin:40px auto;padding:48px;border:1px solid rgba(255,255,255,.1);border-radius:28px;background:linear-gradient(135deg,rgba(247,200,116,.16),rgba(255,255,255,.04))}
    .eyebrow{letter-spacing:.35em;text-transform:uppercase;color:#fde68a;font-size:12px}
    h1{font-size:48px;margin:20px 0 12px}
    h2{font-size:30px;margin:0 0 18px}
    p{font-size:18px;line-height:1.7;color:#e7e5e4}
    .meta{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px;margin-top:28px}
    .card{padding:18px;border-radius:20px;background:rgba(12,18,20,.62);border:1px solid rgba(255,255,255,.08)}
    .label{font-size:11px;letter-spacing:.28em;text-transform:uppercase;color:#a8a29e}
    .value{margin-top:10px;font-size:18px;color:#fff}
  </style>
</head>
<body>
  <main>
    <div class="eyebrow">AI Voice Language Tutor</div>
    <h1>${certificate.title}</h1>
    <p>This certificate is proudly awarded to</p>
    <h2>${certificate.learnerName}</h2>
    <p>${certificate.summary}</p>
    <div class="meta">
      <div class="card"><div class="label">Course</div><div class="value">${certificate.courseName}</div></div>
      <div class="card"><div class="label">Level</div><div class="value">${certificate.officialLabel} · ${certificate.productLabel}</div></div>
      <div class="card"><div class="label">Issued</div><div class="value">${issuedDate}</div></div>
      <div class="card"><div class="label">Certificate ID</div><div class="value">${certificate.id}</div></div>
    </div>
  </main>
</body>
</html>`;
}

export function downloadCertificate(certificate: StoredCertificate) {
  const blob = new Blob([renderCertificateHtml(certificate)], {
    type: "text/html;charset=utf-8",
  });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = getCertificateFileName(certificate);
  anchor.click();
  URL.revokeObjectURL(url);
}

function getCertificateFileName(certificate: StoredCertificate) {
  const base = `${certificate.courseSlug}-${certificate.officialLabel}-certificate`;
  return `${base.toLowerCase().replace(/\s+/g, "-")}.html`;
}
