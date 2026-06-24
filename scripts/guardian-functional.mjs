import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const ROOT = process.cwd();

function fail(message) {
  console.error(`Guardian functional checks failed: ${message}`);
  process.exit(1);
}

function ensureFileIncludes(relativePath, snippets) {
  const fullPath = path.join(ROOT, relativePath);

  if (!existsSync(fullPath)) {
    fail(`missing ${relativePath}`);
  }

  const content = readFileSync(fullPath, "utf8");

  for (const snippet of snippets) {
    if (!content.includes(snippet)) {
      fail(`${relativePath} does not include required content: ${snippet}`);
    }
  }
}

function runBuild() {
  const result = spawnSync("npm", ["run", "build"], {
    cwd: ROOT,
    stdio: "inherit",
    shell: process.platform === "win32",
  });

  if (result.status !== 0) {
    fail("npm run build did not succeed");
  }
}

function main() {
  ensureFileIncludes("src/app/api/health/route.ts", [
    "supabaseConfigured",
    "ok: true",
  ]);
  ensureFileIncludes("src/lib/supabase/client.ts", ["createClient", "getSupabaseEnv"]);
  ensureFileIncludes(".githooks/pre-commit", ["npm run guardian"]);
  runBuild();
  console.log("Guardian functional checks passed.");
}

main();
