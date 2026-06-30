import { type CourseLevel, type CourseSlug } from "@/lib/course-definitions";

function normalizeLevelParam(value: string) {
  return value.trim().toLowerCase();
}

export function getLanguageRoute(slug: CourseSlug) {
  return `/dashboard/${slug}`;
}

export function getLevelRouteParam(level: CourseLevel) {
  return normalizeLevelParam(level.officialLabel);
}

export function getLevelRoute(slug: CourseSlug, level: CourseLevel) {
  return `${getLanguageRoute(slug)}/${getLevelRouteParam(level)}`;
}

export function matchLevelRoute(level: CourseLevel, routeLevel: string) {
  const normalized = normalizeLevelParam(routeLevel);
  return (
    normalizeLevelParam(level.id) === normalized ||
    normalizeLevelParam(level.officialLabel) === normalized
  );
}

export function findLevelByRouteParam(
  levels: CourseLevel[],
  routeLevel: string,
) {
  return levels.find((level) => matchLevelRoute(level, routeLevel)) ?? null;
}
