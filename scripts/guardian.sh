#!/usr/bin/env bash

set -euo pipefail

echo "Running guardian static checks..."
npm run guardian:static

echo "Running lint..."
npm run lint

echo "Running type safety checks..."
npm run typecheck

echo "Running guardian functional checks..."
npm run guardian:functional

echo "Guardian passed."
