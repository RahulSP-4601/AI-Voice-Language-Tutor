create table if not exists public.user_practice_item_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  module_id text not null references public.curriculum_modules(id) on delete cascade,
  item_id text not null,
  done boolean not null default false,
  last_score integer,
  last_transcript text not null default '',
  pronunciation_score integer,
  accuracy_score integer,
  fluency_score integer,
  coaching_feedback text not null default '',
  practiced_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, module_id, item_id)
);

create index if not exists user_practice_item_progress_user_language_module_idx
  on public.user_practice_item_progress (user_id, language_slug, module_id);

alter table public.user_practice_item_progress enable row level security;
drop policy if exists "user_practice_item_progress own rows" on public.user_practice_item_progress;
create policy "user_practice_item_progress own rows"
  on public.user_practice_item_progress
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
