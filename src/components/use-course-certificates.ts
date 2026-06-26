"use client";

import { type Dispatch, type SetStateAction, useEffect, useMemo, useState } from "react";
import {
  buildLevelCertificate,
  createEmptyCertificateCatalog,
  downloadCertificate,
  getCertificateStorageKey,
  hasStoredCertificate,
  loadCertificateCatalog,
  mergeCertificateCatalogs,
  saveCertificateCatalog,
  upsertCertificate,
  type StoredCertificate,
  type StoredCertificateCatalog,
} from "@/lib/course-certificates";
import { type CourseLevel, type LanguageCourseDefinition } from "@/lib/course-definitions";
import { useAccountProfile } from "@/components/use-account-profile";

export function useCourseCertificates() {
  const { profile, ready: accountReady } = useAccountProfile();
  const [sessionCatalog, setSessionCatalog] = useState<StoredCertificateCatalog>(
    createEmptyCertificateCatalog(),
  );
  const catalog = useStoredCertificateCatalog(
    accountReady,
    profile.userId,
    sessionCatalog,
  );

  useEffect(() => {
    if (!accountReady || sessionCatalog.certificates.length === 0) {
      return;
    }

    saveCertificateCatalog(getCertificateStorageKey(profile.userId), catalog);
  }, [accountReady, catalog, profile.userId, sessionCatalog.certificates.length]);

  return useCertificateApi(catalog, profile.name, setSessionCatalog, accountReady);
}

function useStoredCertificateCatalog(
  accountReady: boolean,
  userId: string,
  sessionCatalog: StoredCertificateCatalog,
) {
  return useMemo(() => {
    if (!accountReady) {
      return createEmptyCertificateCatalog();
    }

    const stored = loadCertificateCatalog(
      window.localStorage.getItem(getCertificateStorageKey(userId)),
    );
    return mergeCertificateCatalogs(stored, sessionCatalog);
  }, [accountReady, sessionCatalog, userId]);
}

function useCertificateApi(
  catalog: StoredCertificateCatalog,
  learnerName: string,
  setSessionCatalog: Dispatch<SetStateAction<StoredCertificateCatalog>>,
  ready: boolean,
) {
  return useMemo(
    () => ({
      certificates: catalog.certificates,
      download: (certificate: StoredCertificate) => downloadCertificate(certificate),
      hasCertificate: (courseSlug: LanguageCourseDefinition["slug"], levelId: string) =>
        hasStoredCertificate(catalog, courseSlug, levelId),
      issueLevelCertificate: (course: LanguageCourseDefinition, level: CourseLevel) =>
        setSessionCatalog((current) =>
          upsertCertificate(
            current,
            buildLevelCertificate({ course, learnerName, level }),
          ),
        ),
      ready,
    }),
    [catalog, learnerName, ready, setSessionCatalog],
  );
}
