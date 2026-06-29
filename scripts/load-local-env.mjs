import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const ENV_FILES = [".env.local", ".env"];

function parseLine(line) {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith("#") || !trimmed.includes("=")) {
    return null;
  }

  const separatorIndex = trimmed.indexOf("=");
  const key = trimmed.slice(0, separatorIndex).trim();
  let value = trimmed.slice(separatorIndex + 1).trim();

  if (
    (value.startsWith("\"") && value.endsWith("\"")) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    value = value.slice(1, -1);
  }

  return { key, value };
}

function loadFile(filePath) {
  const content = readFileSync(filePath, "utf8");
  for (const line of content.split(/\r?\n/u)) {
    const entry = parseLine(line);
    if (!entry || process.env[entry.key]) {
      continue;
    }
    process.env[entry.key] = entry.value;
  }
}

export function loadLocalEnv() {
  for (const fileName of ENV_FILES) {
    const filePath = path.resolve(process.cwd(), fileName);
    if (existsSync(filePath)) {
      loadFile(filePath);
    }
  }
}
