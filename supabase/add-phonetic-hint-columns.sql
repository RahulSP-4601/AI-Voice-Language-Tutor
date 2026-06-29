alter table if exists public.curriculum_vocab_entries
  add column if not exists phonetic_hint text not null default '';

alter table if exists public.curriculum_kanji_entries
  add column if not exists phonetic_hint text not null default '';
