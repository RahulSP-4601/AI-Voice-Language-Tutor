import { getSupabaseAdminClient } from "@/lib/supabase/server";

type RateLimitResult = {
  limit: number;
  remaining: number;
  resetAt: number;
  success: boolean;
};

type RateLimitRpcRow = {
  limit_value: number;
  remaining_value: number;
  reset_at: string;
  success: boolean;
};

type RateLimitState = {
  count: number;
  resetAt: number;
};

const rateLimitStore = globalThis as typeof globalThis & {
  __apiRateLimitStore__?: Map<string, RateLimitState>;
};

function getFallbackStore() {
  if (!rateLimitStore.__apiRateLimitStore__) {
    rateLimitStore.__apiRateLimitStore__ = new Map<string, RateLimitState>();
  }

  return rateLimitStore.__apiRateLimitStore__;
}

function pruneExpiredEntries(now: number, store: Map<string, RateLimitState>) {
  for (const [key, value] of store.entries()) {
    if (value.resetAt <= now) {
      store.delete(key);
    }
  }
}

function buildFallbackResult(limit: number, state: RateLimitState): RateLimitResult {
  return {
    limit,
    remaining: Math.max(0, limit - state.count),
    resetAt: state.resetAt,
    success: state.count <= limit,
  };
}

function enforceFallbackRateLimit(input: {
  key: string;
  limit: number;
  windowMs: number;
}) {
  const now = Date.now();
  const store = getFallbackStore();
  pruneExpiredEntries(now, store);

  const existing = store.get(input.key);
  if (!existing || existing.resetAt <= now) {
    const nextState = { count: 1, resetAt: now + input.windowMs };
    store.set(input.key, nextState);
    return buildFallbackResult(input.limit, nextState);
  }

  existing.count += 1;
  store.set(input.key, existing);
  return buildFallbackResult(input.limit, existing);
}

function normalizeRateLimitRow(row: RateLimitRpcRow): RateLimitResult {
  return {
    limit: row.limit_value,
    remaining: row.remaining_value,
    resetAt: new Date(row.reset_at).getTime(),
    success: row.success,
  };
}

function extractRateLimitRow(data: null | RateLimitRpcRow | RateLimitRpcRow[]) {
  if (Array.isArray(data)) {
    return data[0] ?? null;
  }

  return data ?? null;
}

export function getRequestIp(request: Request) {
  const forwardedFor = request.headers.get("x-forwarded-for");
  if (forwardedFor) {
    return forwardedFor.split(",")[0]?.trim() || "anonymous";
  }

  return request.headers.get("x-real-ip")?.trim() || "anonymous";
}

export async function enforceRateLimit(input: {
  key: string;
  limit: number;
  windowMs: number;
}) {
  try {
    const supabase = getSupabaseAdminClient();
    const { data, error } = await supabase.rpc("enforce_api_rate_limit", {
      p_key: input.key,
      p_limit: input.limit,
      p_window_ms: input.windowMs,
    });
    if (error) {
      throw error;
    }

    const row = extractRateLimitRow((data ?? null) as null | RateLimitRpcRow | RateLimitRpcRow[]);
    if (!row) {
      throw new Error("Rate limit RPC returned no data.");
    }

    return normalizeRateLimitRow(row);
  } catch {
    return enforceFallbackRateLimit(input);
  }
}
