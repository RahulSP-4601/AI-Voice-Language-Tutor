function readEnv(name) {
  const value = process.env[name];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value.trim();
}

function buildHeaders() {
  const serviceRoleKey = readEnv("SUPABASE_SERVICE_ROLE_KEY");
  return {
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
    "Content-Type": "application/json",
    Prefer: "return=minimal",
  };
}

function buildRestUrl(table, filterColumn, filterValue) {
  const baseUrl = readEnv("NEXT_PUBLIC_SUPABASE_URL");
  const url = new URL(`/rest/v1/${table}`, baseUrl);
  if (filterColumn) {
    url.searchParams.set(filterColumn, `eq.${filterValue}`);
  }
  return url.toString();
}

async function parseError(response) {
  const text = await response.text();
  return text || `${response.status} ${response.statusText}`;
}

export async function deleteRows(table, column, value) {
  const response = await fetch(buildRestUrl(table, column, value), {
    method: "DELETE",
    headers: buildHeaders(),
  });

  if (!response.ok) {
    throw new Error(`Failed deleting from ${table}: ${await parseError(response)}`);
  }
}

export async function insertRows(table, rows) {
  const response = await fetch(buildRestUrl(table), {
    method: "POST",
    headers: buildHeaders(),
    body: JSON.stringify(rows),
  });

  if (!response.ok) {
    throw new Error(`Failed inserting into ${table}: ${await parseError(response)}`);
  }
}

export async function upsertRows(table, rows, conflictColumn = "id") {
  const url = new URL(buildRestUrl(table));
  url.searchParams.set("on_conflict", conflictColumn);

  const response = await fetch(url.toString(), {
    method: "POST",
    headers: {
      ...buildHeaders(),
      Prefer: "resolution=merge-duplicates,return=minimal",
    },
    body: JSON.stringify(rows),
  });

  if (!response.ok) {
    throw new Error(`Failed upserting into ${table}: ${await parseError(response)}`);
  }
}
