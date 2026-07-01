type RateLimitState = {
  count: number;
  resetAt: number;
};

type RateLimitResult = {
  limit: number;
  remaining: number;
  resetAt: number;
  success: boolean;
};

const rateLimitStore = globalThis as typeof globalThis & {
  __apiRateLimitStore__?: Map<string, RateLimitState>;
};

function getStore() {
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

export function getRequestIp(request: Request) {
  const forwardedFor = request.headers.get("x-forwarded-for");
  if (forwardedFor) {
    return forwardedFor.split(",")[0]?.trim() || "anonymous";
  }

  return request.headers.get("x-real-ip")?.trim() || "anonymous";
}

export function enforceRateLimit(input: {
  key: string;
  limit: number;
  windowMs: number;
}) {
  const now = Date.now();
  const store = getStore();
  pruneExpiredEntries(now, store);

  const existing = store.get(input.key);
  if (!existing || existing.resetAt <= now) {
    const nextState = { count: 1, resetAt: now + input.windowMs };
    store.set(input.key, nextState);
    return buildResult(input.limit, nextState);
  }

  existing.count += 1;
  store.set(input.key, existing);
  return buildResult(input.limit, existing);
}

function buildResult(limit: number, state: RateLimitState): RateLimitResult {
  return {
    limit,
    remaining: Math.max(0, limit - state.count),
    resetAt: state.resetAt,
    success: state.count <= limit,
  };
}
