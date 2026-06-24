# AI Voice Tutor

Starter project built with Next.js App Router, React, TypeScript, Tailwind CSS, and Supabase.

## Getting started

1. Copy `.env.example` to `.env.local`.
2. Add your Supabase project URL and anon key.
3. Run `npm install`.
4. Run `npm run hooks:install`.
5. Start the app with `npm run dev`.

## Guardian

`npm run guardian` runs the full pre-commit protection flow:

- file length limit: 500 lines
- function length limit: 50 lines
- ESLint
- TypeScript type safety
- functional verification plus production build

The pre-commit hook calls `./scripts/guardian.sh`, so commits are blocked until everything passes.
