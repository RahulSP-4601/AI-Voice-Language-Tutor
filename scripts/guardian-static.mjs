import { readFileSync, readdirSync, statSync } from "node:fs";
import path from "node:path";
import ts from "typescript";

const ROOT = process.cwd();
const MAX_FILE_LINES = 500;
const MAX_FUNCTION_LINES = 50;
const SOURCE_EXTENSIONS = new Set([".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs"]);
const IGNORED_DIRS = new Set([".git", ".next", "node_modules", "coverage"]);

function getSourceFiles(directory) {
  const entries = readdirSync(directory, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (!IGNORED_DIRS.has(entry.name)) {
        files.push(...getSourceFiles(fullPath));
      }
      continue;
    }

    if (SOURCE_EXTENSIONS.has(path.extname(entry.name))) {
      files.push(fullPath);
    }
  }

  return files;
}

function countLines(content) {
  return content.split(/\r?\n/).length;
}

function getLineCount(sourceFile, node) {
  return sourceFile.getLineAndCharacterOfPosition(node.end).line -
    sourceFile.getLineAndCharacterOfPosition(node.getStart(sourceFile)).line +
    1;
}

function getFunctionName(node) {
  if ("name" in node && node.name && ts.isIdentifier(node.name)) {
    return node.name.text;
  }

  return "anonymous";
}

function checkFileLength(filePath, issues) {
  const content = readFileSync(filePath, "utf8");
  const lineCount = countLines(content);

  if (lineCount > MAX_FILE_LINES) {
    issues.push(
      `${path.relative(ROOT, filePath)} has ${lineCount} lines. Limit is ${MAX_FILE_LINES}.`,
    );
  }
}

function checkFunctionLengths(filePath, issues) {
  const content = readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(
    filePath,
    content,
    ts.ScriptTarget.Latest,
    true,
  );

  function visit(node) {
    const isFunctionNode =
      ts.isFunctionDeclaration(node) ||
      ts.isFunctionExpression(node) ||
      ts.isArrowFunction(node) ||
      ts.isMethodDeclaration(node);

    if (isFunctionNode) {
      const lineCount = getLineCount(sourceFile, node);

      if (lineCount > MAX_FUNCTION_LINES) {
        issues.push(
          `${path.relative(ROOT, filePath)} has a ${getFunctionName(node)} function with ${lineCount} lines. Limit is ${MAX_FUNCTION_LINES}.`,
        );
      }
    }

    ts.forEachChild(node, visit);
  }

  visit(sourceFile);
}

function ensureProjectLayout(issues) {
  const requiredPaths = [
    "src/app/page.tsx",
    "src/app/layout.tsx",
    "src/app/api/health/route.ts",
    "scripts/guardian.sh",
    ".githooks/pre-commit",
  ];

  for (const relativePath of requiredPaths) {
    const fullPath = path.join(ROOT, relativePath);
    if (!statSafe(fullPath)) {
      issues.push(`Missing required project file: ${relativePath}`);
    }
  }
}

function statSafe(filePath) {
  try {
    return statSync(filePath);
  } catch {
    return null;
  }
}

function main() {
  const files = getSourceFiles(ROOT);
  const issues = [];

  for (const filePath of files) {
    checkFileLength(filePath, issues);
    checkFunctionLengths(filePath, issues);
  }

  ensureProjectLayout(issues);

  if (issues.length > 0) {
    console.error("Guardian static checks failed:");
    for (const issue of issues) {
      console.error(`- ${issue}`);
    }
    process.exit(1);
  }

  console.log("Guardian static checks passed.");
}

main();
