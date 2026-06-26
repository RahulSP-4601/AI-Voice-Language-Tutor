-- Generated from the Japanese N5 curriculum source in this repo.


create extension if not exists pgcrypto;

create table if not exists public.curriculum_languages (
  slug text primary key,
  name text not null,
  framework_name text not null,
  native_support_label text not null,
  hero_summary text not null,
  lesson_duration text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_levels (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  official_label text not null,
  product_label text not null,
  objective text not null,
  exam_title text not null,
  pass_requirement text not null,
  certificate_title text not null,
  certificate_summary text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_modules (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  level_id text not null references public.curriculum_levels(id) on delete cascade,
  title text not null,
  objective text not null,
  checkpoint_label text not null,
  support_language_hint text not null,
  completion_state text not null,
  reward_badge text not null,
  reward_xp integer not null,
  coverage jsonb not null default '[]'::jsonb,
  mission_title text not null,
  story_hook text not null,
  progress_defaults jsonb not null default '{}'::jsonb,
  resource_links jsonb not null default '{}'::jsonb,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_lessons (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  level_id text not null references public.curriculum_levels(id) on delete cascade,
  module_id text not null references public.curriculum_modules(id) on delete cascade,
  title text not null,
  duration_minutes integer not null,
  mode text not null,
  demo_phrase text not null,
  reply_prompt text not null,
  target_pattern text not null,
  learner_outcome text not null,
  acceptable_responses jsonb not null default '[]'::jsonb,
  turns jsonb not null default '[]'::jsonb,
  feedback jsonb not null default '{}'::jsonb,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_vocab_categories (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  title text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_vocab_entries (
  id text primary key,
  category_id text not null references public.curriculum_vocab_categories(id) on delete cascade,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  japanese text not null,
  romaji text not null,
  english text not null,
  example text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_kanji_groups (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  title text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_kanji_entries (
  id text primary key,
  group_id text not null references public.curriculum_kanji_groups(id) on delete cascade,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  japanese text not null,
  reading text not null,
  meaning text not null,
  example text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_exam_sections (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  title text not null,
  coverage jsonb not null default '[]'::jsonb,
  question_types jsonb not null default '[]'::jsonb,
  pass_signal text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.curriculum_exam_questions (
  id text primary key,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  section_id text not null references public.curriculum_exam_sections(id) on delete cascade,
  skill_focus text not null,
  prompt text not null,
  question_type text not null,
  choices jsonb not null default '[]'::jsonb,
  correct_answer text not null,
  explanation text not null,
  sort_order integer not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_module_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  module_id text not null references public.curriculum_modules(id) on delete cascade,
  state text not null default 'not_started',
  current_turn integer not null default 0,
  last_transcript text not null default '',
  sessions_started integer not null default 0,
  completed_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, module_id)
);

create table if not exists public.user_module_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  module_id text not null references public.curriculum_modules(id) on delete cascade,
  lesson_id text references public.curriculum_lessons(id) on delete cascade,
  transcript text not null default '',
  pronunciation_score integer,
  accuracy_score integer,
  fluency_score integer,
  coaching_feedback text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_level_certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  language_slug text not null references public.curriculum_languages(slug) on delete cascade,
  level_id text not null references public.curriculum_levels(id) on delete cascade,
  certificate_title text not null,
  certificate_summary text not null,
  certificate_html text not null,
  issued_at timestamptz not null default timezone('utc', now()),
  unique (user_id, level_id)
);


alter table public.curriculum_languages enable row level security;
drop policy if exists "curriculum_languages public read" on public.curriculum_languages;
create policy "curriculum_languages public read" on public.curriculum_languages for select using (true);
alter table public.curriculum_levels enable row level security;
drop policy if exists "curriculum_levels public read" on public.curriculum_levels;
create policy "curriculum_levels public read" on public.curriculum_levels for select using (true);
alter table public.curriculum_modules enable row level security;
drop policy if exists "curriculum_modules public read" on public.curriculum_modules;
create policy "curriculum_modules public read" on public.curriculum_modules for select using (true);
alter table public.curriculum_lessons enable row level security;
drop policy if exists "curriculum_lessons public read" on public.curriculum_lessons;
create policy "curriculum_lessons public read" on public.curriculum_lessons for select using (true);
alter table public.curriculum_vocab_categories enable row level security;
drop policy if exists "curriculum_vocab_categories public read" on public.curriculum_vocab_categories;
create policy "curriculum_vocab_categories public read" on public.curriculum_vocab_categories for select using (true);
alter table public.curriculum_vocab_entries enable row level security;
drop policy if exists "curriculum_vocab_entries public read" on public.curriculum_vocab_entries;
create policy "curriculum_vocab_entries public read" on public.curriculum_vocab_entries for select using (true);
alter table public.curriculum_kanji_groups enable row level security;
drop policy if exists "curriculum_kanji_groups public read" on public.curriculum_kanji_groups;
create policy "curriculum_kanji_groups public read" on public.curriculum_kanji_groups for select using (true);
alter table public.curriculum_kanji_entries enable row level security;
drop policy if exists "curriculum_kanji_entries public read" on public.curriculum_kanji_entries;
create policy "curriculum_kanji_entries public read" on public.curriculum_kanji_entries for select using (true);
alter table public.curriculum_exam_sections enable row level security;
drop policy if exists "curriculum_exam_sections public read" on public.curriculum_exam_sections;
create policy "curriculum_exam_sections public read" on public.curriculum_exam_sections for select using (true);
alter table public.curriculum_exam_questions enable row level security;
drop policy if exists "curriculum_exam_questions public read" on public.curriculum_exam_questions;
create policy "curriculum_exam_questions public read" on public.curriculum_exam_questions for select using (true);
alter table public.user_module_progress enable row level security;
drop policy if exists "user_module_progress own rows" on public.user_module_progress;
create policy "user_module_progress own rows" on public.user_module_progress using (auth.uid() = user_id) with check (auth.uid() = user_id);
alter table public.user_module_attempts enable row level security;
drop policy if exists "user_module_attempts own rows" on public.user_module_attempts;
create policy "user_module_attempts own rows" on public.user_module_attempts using (auth.uid() = user_id) with check (auth.uid() = user_id);
alter table public.user_level_certificates enable row level security;
drop policy if exists "user_level_certificates own rows" on public.user_level_certificates;
create policy "user_level_certificates own rows" on public.user_level_certificates using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into public.curriculum_languages (slug, name, framework_name, native_support_label, hero_summary, lesson_duration)
values
  ('japanese', 'Japanese', 'JLPT', 'Native-language support active for beginner correction', 'Learn Japanese from absolute zero through a full lesson-dense JLPT N5 journey taught in English with romaji support, kana, grammar, roleplay, and a free final certificate.', '15-20 minute voice lesson')
on conflict (slug) do update set
  name = excluded.name,
  framework_name = excluded.framework_name,
  native_support_label = excluded.native_support_label,
  hero_summary = excluded.hero_summary,
  lesson_duration = excluded.lesson_duration;

insert into public.curriculum_levels (id, language_slug, official_label, product_label, objective, exam_title, pass_requirement, certificate_title, certificate_summary, sort_order)
values
  ('jp-n5', 'japanese', 'N5', 'Basic 1', 'Build complete beginner-safe Japanese from romaji and sounds to kana, grammar, roleplay, and the final N5 certificate challenge.', 'JLPT N5 complete certificate exam', 'Complete every N5 mission and clear the final guided voice exam to unlock the course certificate.', 'JLPT N5 completion certificate', 'Issued after the learner completes the full N5 journey and passes the final guided certificate exam.', 0)
on conflict (id) do update set
  official_label = excluded.official_label,
  product_label = excluded.product_label,
  objective = excluded.objective,
  exam_title = excluded.exam_title,
  pass_requirement = excluded.pass_requirement,
  certificate_title = excluded.certificate_title,
  certificate_summary = excluded.certificate_summary,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-japanese-overview', 'japanese', 'jp-n5', 'What is Japanese?', 'Introduce Japanese in simple English so the learner knows what the language is and why this journey matters.', 'Japan map check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'First Step in Japan', 10, $json$["What Japanese is","Beginner-safe course overview","Learning promise"]$json$::jsonb, 'Mission 1: Enter Japan with a clear map', 'You have just landed in Tokyo and everything looks mysterious. This first mission explains the map before you start speaking.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-japanese-overview', 'japanese', 'jp-n5', 'n5-japanese-overview', 'What is Japanese?', 18, 'listening', 'nihongo', 'Say nihongo clearly once.', 'course orientation', 'Learner understands the course promise and feels safe starting from zero.', $json$["nihongo","にほんご"]$json$::jsonb, $json$[{"id":"n5-japanese-overview-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-japanese-overview-model","label":"AI models the phrase","type":"ai_model","prompt":"Explain that Japanese will unlock step by step through sound, script, words, and real conversation.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-japanese-overview-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-japanese-overview-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-japanese-overview-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-japanese-overview-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what they expect from the course, then have them say nihongo aloud.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-japanese-overview-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Confirm the learner understands this is a full beginner journey.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-japanese-overview-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-japanese-vs-english', 'japanese', 'jp-n5', 'How Japanese differs from English', 'Show the learner in English how Japanese differs from English rhythm, script, and sentence feeling.', 'Difference awareness', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Mindset Reset', 10, $json$["Sentence order awareness","Rhythm differences","Why translation is not enough"]$json$::jsonb, 'Mission 2: Reset your English habits', 'English habits are helpful, but they can also trip you up. This mission helps you reset before practice begins.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 1)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-japanese-vs-english', 'japanese', 'jp-n5', 'n5-japanese-vs-english', 'How Japanese differs from English', 18, 'listening', 'watashi wa Rahul desu', 'Repeat the sample sentence once with calm pacing.', 'English versus Japanese rhythm', 'Learner stops expecting Japanese to behave exactly like English.', $json$["watashi wa rahul desu","わたしは ラフルです"]$json$::jsonb, $json$[{"id":"n5-japanese-vs-english-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-japanese-vs-english-model","label":"AI models the phrase","type":"ai_model","prompt":"Model one beginner sentence and explain how Japanese sounds more even and less stress-heavy than English.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-japanese-vs-english-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-japanese-vs-english-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-japanese-vs-english-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-japanese-vs-english-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what felt different, then have them repeat the sentence once more.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-japanese-vs-english-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner notices one clear difference between English and Japanese.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-japanese-vs-english-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-no-abcd', 'japanese', 'jp-n5', 'Japanese does not use ABCD', 'Teach in English that Japanese does not use the English alphabet as its native writing system.', 'Script awareness', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Script Explorer', 10, $json$["Why ABCD is not the base","Three writing systems","Beginner expectation setting"]$json$::jsonb, 'Mission 3: Meet the real Japanese scripts', 'You look for A, B, C, and D on the signs and do not find them. This mission explains what Japan uses instead.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 2)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-no-abcd', 'japanese', 'jp-n5', 'n5-no-abcd', 'Japanese does not use ABCD', 18, 'listening', 'hiragana, katakana, kanji', 'Say hiragana, katakana, and kanji in order.', 'script introduction', 'Learner understands the three core Japanese writing systems.', $json$["hiragana katakana kanji","ひらがな","カタカナ","かんじ"]$json$::jsonb, $json$[{"id":"n5-no-abcd-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-no-abcd-model","label":"AI models the phrase","type":"ai_model","prompt":"Introduce hiragana, katakana, and kanji as three friendly doors instead of one overwhelming wall.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-no-abcd-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-no-abcd-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-no-abcd-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-no-abcd-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the three script names and identify which one feels most new.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-no-abcd-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner can name the three writing systems aloud.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-no-abcd-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-romaji-intro', 'japanese', 'jp-n5', 'What is Romaji?', 'Use English teaching to explain romaji as a bridge from familiar letters into Japanese sound.', 'Romaji bridge check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Romaji Bridge Badge', 15, $json$["What romaji is","Why it helps beginners","Why it is only a bridge"]$json$::jsonb, 'Mission 4: Cross the romaji bridge', 'You recognize sushi and arigatou in English letters first. Romaji becomes your first safe bridge into Japanese.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 3)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-romaji-intro', 'japanese', 'jp-n5', 'n5-romaji-intro', 'What is Romaji?', 18, 'repeat', 'sushi, arigatou, nihon', 'Read sushi, arigatou, and nihon aloud in Japanese rhythm.', 'romaji introduction', 'Learner can use romaji for support without mistaking it for the final goal.', $json$["sushi","arigatou","nihon","すし","ありがとう","にほん"]$json$::jsonb, $json$[{"id":"n5-romaji-intro-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-romaji-intro-model","label":"AI models the phrase","type":"ai_model","prompt":"Model three familiar romaji words and explain that they point toward real Japanese pronunciation.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-romaji-intro-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-romaji-intro-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-romaji-intro-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-romaji-intro-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read the three words and then say which one felt easiest.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-romaji-intro-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the romaji bridge with three safe starter words.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-romaji-intro-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-romaji-vowels', 'japanese', 'jp-n5', 'Japanese vowels in Romaji', 'Teach aiueo in English through romaji so the learner hears Japanese vowels before script pressure appears.', 'Vowel bridge check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Vowel Master', 15, $json$["a i u e o","English comparison hints","Mouth shape and timing"]$json$::jsonb, 'Mission 5: Hear the five core sounds', 'Every future word depends on five vowel sounds. This mission makes them feel friendly before kana arrives.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 4)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-romaji-vowels', 'japanese', 'jp-n5', 'n5-romaji-vowels', 'Japanese vowels in Romaji', 18, 'repeat', 'a, i, u, e, o', 'Say a, i, u, e, o once with even rhythm.', 'aiueo', 'Learner can repeat aiueo with steady beginner confidence.', $json$["a i u e o","aiueo","あいうえお"]$json$::jsonb, $json$[{"id":"n5-romaji-vowels-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-romaji-vowels-model","label":"AI models the phrase","type":"ai_model","prompt":"Model aiueo slowly and then naturally so the learner hears clean Japanese vowel timing.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-romaji-vowels-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-romaji-vowels-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-romaji-vowels-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-romaji-vowels-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the full line, then retry the hardest vowel.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-romaji-vowels-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner can say aiueo without stopping.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-romaji-vowels-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-mini-vowel-words', 'japanese', 'jp-n5', 'Mini vowel words', 'Move from isolated vowels into tiny beginner words that make sound practice feel useful.', 'Mini word check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'First Sound Badge', 10, $json$["あい","いえ","うえ","Early word rhythm"]$json$::jsonb, 'Mission 6: Turn vowels into tiny words', 'You start hearing Japanese not as abstract sounds but as real words like ie and ue.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 5)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-mini-vowel-words', 'japanese', 'jp-n5', 'n5-mini-vowel-words', 'Mini vowel words', 18, 'speaking', 'ai, ie, ue', 'Say ai, ie, and ue clearly once.', 'vowel-based words', 'Learner can connect vowels to tiny spoken words.', $json$["ai ie ue","あい","いえ","うえ"]$json$::jsonb, $json$[{"id":"n5-mini-vowel-words-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-mini-vowel-words-model","label":"AI models the phrase","type":"ai_model","prompt":"Model tiny beginner words so the learner feels the jump from pure sound into meaning.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-mini-vowel-words-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-mini-vowel-words-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-mini-vowel-words-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-mini-vowel-words-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the words and identify which one means house.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-mini-vowel-words-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the first tiny-word mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-mini-vowel-words-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-k-row', 'japanese', 'jp-n5', 'K-row sounds', 'Teach the first consonant-plus-vowel row so Japanese sound structure becomes visible.', 'K-row check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'K-Row Starter', 10, $json$["ka ki ku ke ko","Row rhythm","Kana sound expectation"]$json$::jsonb, 'Mission 7: Unlock the ka-row', 'This is the moment Japanese starts behaving like a system. The ka-row opens the first real row pattern.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 6)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-k-row', 'japanese', 'jp-n5', 'n5-k-row', 'K-row sounds', 18, 'repeat', 'ka ki ku ke ko', 'Say ka ki ku ke ko once in order.', 'k-row practice', 'Learner can say the full ka-row clearly.', $json$["ka ki ku ke ko","かきくけこ"]$json$::jsonb, $json$[{"id":"n5-k-row-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-k-row-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the ka-row like a calm rhythm drill, not a textbook chant.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-k-row-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-k-row-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-k-row-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-k-row-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the full row and then isolate ko for one cleaner retry.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-k-row-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner says the full ka-row in one pass.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-k-row-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-s-row', 'japanese', 'jp-n5', 'S-row sounds', 'Teach the sa-row and its special shi sound in clear English support.', 'S-row check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'S-Row Starter', 10, $json$["sa shi su se so","Special shi sound","Contrast with English sh"]$json$::jsonb, 'Mission 8: Unlock the sa-row', 'The sa-row adds the first beginner irregularity, and that makes it an important listening mission.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 7)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-s-row', 'japanese', 'jp-n5', 'n5-s-row', 'S-row sounds', 18, 'repeat', 'sa shi su se so', 'Say sa shi su se so clearly in order.', 's-row practice', 'Learner can hear and repeat the sa-row accurately.', $json$["sa shi su se so","さしすせそ"]$json$::jsonb, $json$[{"id":"n5-s-row-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-s-row-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the sa-row with special attention to shi so the learner hears the contrast immediately.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-s-row-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-s-row-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-s-row-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-s-row-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the row and retry shi once with smoother timing.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-s-row-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the sa-row with a clean shi.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-s-row-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-t-row', 'japanese', 'jp-n5', 'T-row sounds', 'Teach ta, chi, tsu, te, and to in a beginner-safe voice loop.', 'T-row check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'T-Row Starter', 10, $json$["ta chi tsu te to","chi and tsu contrast","Breath control"]$json$::jsonb, 'Mission 9: Unlock the ta-row', 'The ta-row introduces more Japanese sound personality. This mission makes chi and tsu less intimidating.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 8)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-t-row', 'japanese', 'jp-n5', 'n5-t-row', 'T-row sounds', 18, 'repeat', 'ta chi tsu te to', 'Say ta chi tsu te to once in order.', 't-row practice', 'Learner can repeat the full ta-row with more confidence.', $json$["ta chi tsu te to","たちつてと"]$json$::jsonb, $json$[{"id":"n5-t-row-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-t-row-model","label":"AI models the phrase","type":"ai_model","prompt":"Model chi and tsu carefully so the learner hears them as manageable sounds, not traps.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-t-row-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-t-row-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-t-row-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-t-row-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner for the full row and then repeat tsu once slowly.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-t-row-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the ta-row without freezing on chi or tsu.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-t-row-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-n-h-rows', 'japanese', 'jp-n5', 'N and H rows', 'Add the n-row and h-row so the learner starts hearing larger patterns across Japanese.', 'N and H row check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Row Builder', 10, $json$["na-row","ha-row","Special fu sound","Comparing rows"]$json$::jsonb, 'Mission 10: Expand your beginner sound map', 'With more rows unlocked, Japanese starts feeling like a living sound grid instead of a mystery.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 9)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-n-h-rows', 'japanese', 'jp-n5', 'n5-n-h-rows', 'N and H rows', 18, 'speaking', 'na ni nu ne no, ha hi fu he ho', 'Say the na-row, then the ha-row with special care on fu.', 'n-row and h-row', 'Learner can speak two rows and notice how fu differs from English expectations.', $json$["na ni nu ne no","ha hi fu he ho","なにぬねの","はひふへほ"]$json$::jsonb, $json$[{"id":"n5-n-h-rows-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-n-h-rows-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the two rows clearly and explain fu in one short English note before returning to speech.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-n-h-rows-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-n-h-rows-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-n-h-rows-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-n-h-rows-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner for both rows and one cleaner retry of fu.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-n-h-rows-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes two rows with a usable fu sound.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-n-h-rows-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-m-y-r-w-rows', 'japanese', 'jp-n5', 'M, Y, R, and W rows', 'Complete the main beginner sound rows so the learner can prepare for kana with stronger rhythm awareness.', 'Core sound map complete', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Sound Map Complete', 15, $json$["ma-row","ya yu yo","ra-row","wa wo n","Whole sound map review"]$json$::jsonb, 'Mission 11: Finish the core sound map', 'This mission closes the loop on the core Japanese sound map and prepares you for script mastery.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 10)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-m-y-r-w-rows', 'japanese', 'jp-n5', 'n5-m-y-r-w-rows', 'M, Y, R, and W rows', 18, 'speaking', 'ma mi mu me mo, ya yu yo, ra ri ru re ro, wa wo n', 'Say the ma-row, the ya-yu-yo set, the ra-row, and wa-wo-n.', 'final core rows', 'Learner can move through the final core rows with more comfort and momentum.', $json$["ma mi mu me mo","ya yu yo","ra ri ru re ro","wa wo n","まみむめも"]$json$::jsonb, $json$[{"id":"n5-m-y-r-w-rows-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-m-y-r-w-rows-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the remaining rows like a complete beginner sound map ready for kana practice.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-m-y-r-w-rows-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-m-y-r-w-rows-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-m-y-r-w-rows-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-m-y-r-w-rows-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to move through each group and then repeat the ra-row once more.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-m-y-r-w-rows-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner finishes the full pre-kana sound map.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-m-y-r-w-rows-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-romaji-to-hiragana', 'japanese', 'jp-n5', 'Moving from Romaji to Hiragana', 'Prepare the learner to shift from romaji support into true hiragana reading.', 'Romaji exit check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Bridge Complete', 15, $json$["Romaji fade-out","First hiragana targets","Confidence shift into script"]$json$::jsonb, 'Mission 12: Leave the bridge behind', 'The bridge has done its job. Now you start stepping onto real Japanese script without losing confidence.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 11)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-romaji-to-hiragana', 'japanese', 'jp-n5', 'n5-romaji-to-hiragana', 'Moving from Romaji to Hiragana', 18, 'listening', 'すし, ねこ, にほん', 'Read sushi, neko, and nihon using the script if you can.', 'romaji to hiragana transition', 'Learner feels ready to enter the hiragana section without panic.', $json$["sushi","neko","nihon","すし","ねこ","にほん"]$json$::jsonb, $json$[{"id":"n5-romaji-to-hiragana-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-romaji-to-hiragana-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the same word first in romaji, then in hiragana, and explain the shift in one simple English line.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-romaji-to-hiragana-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-romaji-to-hiragana-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-romaji-to-hiragana-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-romaji-to-hiragana-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read the three words and notice how much less they need the romaji now.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-romaji-to-hiragana-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner is ready to begin true hiragana lessons.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-romaji-to-hiragana-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-a-row', 'japanese', 'jp-n5', 'Hiragana a-row', 'Teach あいうえお in English with voice-first guidance so the learner reads the first real hiragana row.', 'A-row reading check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Hiragana Hero', 15, $json$["あいうえお","Sound-to-symbol link","First script confidence"]$json$::jsonb, 'Mission 13: Read your first Japanese letters', 'You see あいうえお for the first time and realize Japanese script is finally becoming readable.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 12)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-a-row', 'japanese', 'jp-n5', 'n5-hiragana-a-row', 'Hiragana a-row', 18, 'listening', 'あ い う え お', 'Read あ い う え お in order.', 'hiragana a-row', 'Learner can read and say the hiragana a-row aloud.', $json$["あいうえお","a i u e o"]$json$::jsonb, $json$[{"id":"n5-hiragana-a-row-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-a-row-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the a-row as symbols the learner can already hear from aiueo.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-a-row-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-a-row-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-a-row-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-a-row-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read the five characters and repeat the hardest one once more.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-a-row-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the first hiragana row.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-a-row-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-k-row', 'japanese', 'jp-n5', 'Hiragana k-row', 'Connect the ka-row sounds to their hiragana symbols in a clean beginner voice lesson.', 'K-row reading check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Kana Row Starter', 10, $json$["かきくけこ","Sound row to symbol row","Reading confidence"]$json$::jsonb, 'Mission 14: Read かきくけこ', 'The sound map now becomes script. You can finally see and say かきくけこ as one system.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 13)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-k-row', 'japanese', 'jp-n5', 'n5-hiragana-k-row', 'Hiragana k-row', 18, 'listening', 'か き く け こ', 'Read か き く け こ in order.', 'hiragana k-row', 'Learner reads and says the hiragana k-row accurately.', $json$["かきくけこ","ka ki ku ke ko"]$json$::jsonb, $json$[{"id":"n5-hiragana-k-row-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-k-row-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the k-row visually and vocally so the learner sees the row they already know by sound.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-k-row-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-k-row-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-k-row-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-k-row-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read each character, then read the whole row once smoothly.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-k-row-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the hiragana k-row.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-k-row-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-s-t-rows', 'japanese', 'jp-n5', 'Hiragana s and t rows', 'Teach さしすせそ and たちつてと with voice emphasis on し, ち, and つ.', 'S and T row reading', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Row Reader', 10, $json$["さしすせそ","たちつてと","し ち つ contrast"]$json$::jsonb, 'Mission 15: Read the rows with special sounds', 'These rows teach you that Japanese letters sometimes hide special sounds, but they are still learnable.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 14)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-s-t-rows', 'japanese', 'jp-n5', 'n5-hiragana-s-t-rows', 'Hiragana s and t rows', 18, 'listening', 'さ し す せ そ, た ち つ て と', 'Read the s-row and t-row once in order.', 'hiragana s and t rows', 'Learner reads two key hiragana rows with better precision.', $json$["さしすせそ","たちつてと","sa shi su se so","ta chi tsu te to"]$json$::jsonb, $json$[{"id":"n5-hiragana-s-t-rows-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-s-t-rows-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the rows with extra clarity on し, ち, and つ so reading and sound stay connected.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-s-t-rows-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-s-t-rows-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-s-t-rows-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-s-t-rows-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read both rows and retry つ once more if needed.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-s-t-rows-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner reads the s-row and t-row with a usable special-sound contrast.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-s-t-rows-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-n-h-rows', 'japanese', 'jp-n5', 'Hiragana n and h rows', 'Teach the n-row and h-row with clear English support for ふ.', 'N and H row reading', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Reading Builder', 10, $json$["な-row","は-row","ふ as a special beginner sound"]$json$::jsonb, 'Mission 16: Expand hiragana reading power', 'The more rows you read, the more Japanese words stop looking impossible and start looking familiar.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 15)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-n-h-rows', 'japanese', 'jp-n5', 'n5-hiragana-n-h-rows', 'Hiragana n and h rows', 18, 'listening', 'な に ぬ ね の, は ひ ふ へ ほ', 'Read the n-row and h-row aloud.', 'hiragana n and h rows', 'Learner reads and says two more hiragana rows confidently.', $json$["なにぬねの","はひふへほ","na ni nu ne no","ha hi fu he ho"]$json$::jsonb, $json$[{"id":"n5-hiragana-n-h-rows-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-n-h-rows-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the rows clearly and explain ふ in one short English line before continuing.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-n-h-rows-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-n-h-rows-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-n-h-rows-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-n-h-rows-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read both rows and pause briefly on ふ for one cleaner pass.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-n-h-rows-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner handles both rows and notices ふ correctly.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-n-h-rows-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-m-y-r-w', 'japanese', 'jp-n5', 'Remaining hiragana rows', 'Complete the remaining hiragana rows and symbols so the learner owns the full 46-character chart.', 'Full hiragana chart ready', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Hiragana Chart Complete', 20, $json$["ま-row","やゆよ","ら-row","わをん","46-character completion"]$json$::jsonb, 'Mission 17: Finish the basic hiragana chart', 'This mission completes the core hiragana map and turns the script from mystery into something familiar.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 16)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-m-y-r-w', 'japanese', 'jp-n5', 'n5-hiragana-m-y-r-w', 'Remaining hiragana rows', 18, 'speaking', 'ま み む め も, や ゆ よ, ら り る れ ろ, わ を ん', 'Read the remaining rows and the final symbols in order.', 'remaining hiragana rows', 'Learner can move across the remaining basic hiragana chart with confidence.', $json$["まみむめも","やゆよ","らりるれろ","わをん"]$json$::jsonb, $json$[{"id":"n5-hiragana-m-y-r-w-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-m-y-r-w-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the remaining rows as the final pieces of the hiragana map.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-m-y-r-w-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-m-y-r-w-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-m-y-r-w-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-m-y-r-w-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read each group and then say ん once clearly at the end.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-m-y-r-w-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the full basic hiragana set.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-m-y-r-w-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-words', 'japanese', 'jp-n5', 'Hiragana words', 'Use easy hiragana words so script practice turns into meaning and fun.', 'Hiragana word mission', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Word Reader', 15, $json$["Food words","Animal words","Place words","Meaning plus reading"]$json$::jsonb, 'Mission 18: Read your first real Japanese words', 'Reading すし, ねこ, and にほん is the first moment many beginners feel real joy in Japanese.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 17)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-words', 'japanese', 'jp-n5', 'n5-hiragana-words', 'Hiragana words', 18, 'speaking', 'すし, ねこ, いぬ, にほん', 'Read sushi, cat, dog, and Japan aloud.', 'hiragana word reading', 'Learner reads familiar hiragana words instead of isolated symbols only.', $json$["すし","ねこ","いぬ","にほん","sushi","neko"]$json$::jsonb, $json$[{"id":"n5-hiragana-words-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-words-model","label":"AI models the phrase","type":"ai_model","prompt":"Model beginner hiragana words with natural meaning and rhythm so script feels alive.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-words-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-words-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-words-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-words-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read each word and then say which one means Japan.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-words-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner reads four common hiragana words successfully.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-words-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-dakuon', 'japanese', 'jp-n5', 'Hiragana dakuon', 'Teach voiced hiragana like が and ざ so the learner can handle a wider range of N5 words.', 'Dakuon check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Voiced Sound Badge', 15, $json$["が-row","ざ-row","だ-row","ば-row","Voiced-word practice"]$json$::jsonb, 'Mission 19: Add voiced hiragana sounds', 'Two small marks change the sound and unlock many real words. This mission trains that jump.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 18)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-dakuon', 'japanese', 'jp-n5', 'n5-hiragana-dakuon', 'Hiragana dakuon', 18, 'repeat', 'が ぎ ぐ げ ご, ざ じ ず ぜ ぞ', 'Repeat the が-row and ざ-row once clearly.', 'dakuon practice', 'Learner can hear and repeat core dakuon sounds with less confusion.', $json$["がぎぐげご","ざじずぜぞ","ga gi gu ge go"]$json$::jsonb, $json$[{"id":"n5-hiragana-dakuon-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-dakuon-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the voiced rows and connect them to words like がくせい and でんわ.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-dakuon-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-dakuon-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-dakuon-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-dakuon-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the rows and one dakuon word.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-dakuon-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes voiced row practice successfully.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-dakuon-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-handakuon-yoon', 'japanese', 'jp-n5', 'Handakuon and yoon', 'Teach ぱ-row sounds and small や ゆ よ combinations in a friendly speaking loop.', 'Handakuon and yoon', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Glide Sound Badge', 15, $json$["ぱ-row","きゃ/きゅ/きょ","しゃ/しゅ/しょ","ちゃ/ちゅ/ちょ"]$json$::jsonb, 'Mission 20: Handle circles and glide sounds', 'A small circle and a small ya-yu-yo can completely change a word. This mission makes those changes feel manageable.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 19)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-handakuon-yoon', 'japanese', 'jp-n5', 'n5-hiragana-handakuon-yoon', 'Handakuon and yoon', 18, 'repeat', 'ぱ ぴ ぷ ぺ ぽ, きゃ きゅ きょ', 'Repeat the ぱ-row and one yoon set clearly.', 'handakuon and yoon', 'Learner can repeat beginner handakuon and yoon sounds with more control.', $json$["ぱぴぷぺぽ","きゃきゅきょ","pa pi pu pe po"]$json$::jsonb, $json$[{"id":"n5-hiragana-handakuon-yoon-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-handakuon-yoon-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the ぱ-row and a few yoon combinations through fun beginner words.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-handakuon-yoon-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-handakuon-yoon-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-handakuon-yoon-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-handakuon-yoon-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat one row and one glide set, then retry the harder one.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-handakuon-yoon-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner handles both handakuon and yoon practice.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-handakuon-yoon-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-sokuon-choun', 'japanese', 'jp-n5', 'Sokuon and long vowels', 'Teach small っ and long vowels so the learner hears timing differences that change meaning.', 'Timing contrast check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Timing Master', 15, $json$["Small っ pause","Double consonants","Long vowels","Meaning contrast"]$json$::jsonb, 'Mission 21: Hear pauses and long sound changes', 'A tiny pause can change a word completely. This mission teaches the timing details that make Japanese sound real.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 20)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-sokuon-choun', 'japanese', 'jp-n5', 'n5-hiragana-sokuon-choun', 'Sokuon and long vowels', 18, 'repeat', 'がっこう, きっぷ, おばさん, おばあさん', 'Repeat gakkou, kippu, obasan, and obaasan with clear timing.', 'sokuon and long vowels', 'Learner can repeat and notice timing-based differences more clearly.', $json$["gakkou","kippu","obasan","obaasan","がっこう","きっぷ"]$json$::jsonb, $json$[{"id":"n5-hiragana-sokuon-choun-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-sokuon-choun-model","label":"AI models the phrase","type":"ai_model","prompt":"Model pause words and long-vowel pairs so the learner hears how meaning can shift with timing.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-sokuon-choun-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-sokuon-choun-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-sokuon-choun-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-sokuon-choun-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the pause word and the long-vowel contrast pair.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-sokuon-choun-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner finishes the hiragana timing mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-sokuon-choun-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-hiragana-reading-writing', 'japanese', 'jp-n5', 'Full hiragana practice', 'Review the full hiragana chart through reading, writing awareness, and confident voice practice in English.', 'Hiragana mastery check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Hiragana Hero', 20, $json$["Full chart review","Word reading","Writing awareness","Special sounds recap"]$json$::jsonb, 'Mission 22: Lock in the full hiragana system', 'This is the consolidation mission where the hiragana chart stops feeling fragile and starts feeling like yours.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["hiragana","special-kana","reading"],"vocabularyCategoryIds":["greetings","food","places"]}$json$::jsonb, 21)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-hiragana-reading-writing', 'japanese', 'jp-n5', 'n5-hiragana-reading-writing', 'Full hiragana practice', 18, 'checkpoint', 'あいうえお, かきくけこ, すし, にほん', 'Read one row, one word, and one special-sound word clearly.', 'full hiragana review', 'Learner can move through hiragana with stronger confidence before katakana begins.', $json$["あいうえお","かきくけこ","すし","にほん"]$json$::jsonb, $json$[{"id":"n5-hiragana-reading-writing-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-reading-writing-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a compact hiragana review that feels like a success lap rather than a heavy exam.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-hiragana-reading-writing-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-hiragana-reading-writing-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-hiragana-reading-writing-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-hiragana-reading-writing-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner for one row, one word, and one special sound example to complete the review.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-hiragana-reading-writing-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner is ready to move into katakana.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-hiragana-reading-writing-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-overview', 'japanese', 'jp-n5', 'What is Katakana?', 'Explain in English what katakana is used for and why it matters in travel, food, names, and technology.', 'Katakana overview', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Katakana Explorer', 10, $json$["Foreign words","Names","Country words","Technology and food vocabulary"]$json$::jsonb, 'Mission 23: Enter the world of Japanese modern words', 'From airports to coffee shops, katakana is everywhere in modern Japan. This mission opens that door.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 22)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-overview', 'japanese', 'jp-n5', 'n5-katakana-overview', 'What is Katakana?', 18, 'listening', 'ホテル, バス, コーヒー', 'Say hotel, bus, and coffee in Japanese rhythm.', 'katakana purpose', 'Learner understands why katakana matters before learning the chart.', $json$["ホテル","バス","コーヒー","hoteru","basu","koohii"]$json$::jsonb, $json$[{"id":"n5-katakana-overview-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-overview-model","label":"AI models the phrase","type":"ai_model","prompt":"Introduce katakana as the script of modern and imported vocabulary the learner will hear often.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-overview-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-overview-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-overview-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-overview-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the three sample words and notice the Japanese rhythm inside them.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-overview-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner understands why katakana appears in daily Japanese life.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-overview-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-a-k', 'japanese', 'jp-n5', 'Katakana a and k rows', 'Teach アイウエオ and カキクケコ with sound-first support so the learner sees katakana as familiar, not alien.', 'Katakana row check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Katakana Starter', 10, $json$["アイウエオ","カキクケコ","Sound continuity from hiragana"]$json$::jsonb, 'Mission 24: Read your first katakana rows', 'The shapes look sharper than hiragana, but the sounds are already inside you. This mission proves that fast.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 23)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-a-k', 'japanese', 'jp-n5', 'n5-katakana-a-k', 'Katakana a and k rows', 18, 'listening', 'ア イ ウ エ オ, カ キ ク ケ コ', 'Read the a-row and k-row in katakana.', 'katakana first rows', 'Learner can read the first katakana rows with confidence.', $json$["アイウエオ","カキクケコ","a i u e o","ka ki ku ke ko"]$json$::jsonb, $json$[{"id":"n5-katakana-a-k-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-a-k-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the rows as familiar sounds in new shapes so the learner feels continuity rather than fear.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-a-k-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-a-k-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-a-k-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-a-k-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read both rows and say which shape group felt easier.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-a-k-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the first katakana rows.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-a-k-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-s-t', 'japanese', 'jp-n5', 'Katakana s and t rows', 'Teach サシスセソ and タチツテト with beginner support for シ and ツ contrast.', 'Katakana contrast check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Katakana Contrast', 10, $json$["サ-row","タ-row","シ vs ツ awareness","Reading stability"]$json$::jsonb, 'Mission 25: Read more katakana with special sounds', 'Katakana can be visually tricky, so this mission slows down just enough to make the patterns feel reliable.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 24)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-s-t', 'japanese', 'jp-n5', 'n5-katakana-s-t', 'Katakana s and t rows', 18, 'listening', 'サ シ ス セ ソ, タ チ ツ テ ト', 'Read the s-row and t-row in katakana.', 'katakana contrast rows', 'Learner reads these katakana rows with better visual and sound control.', $json$["サシスセソ","タチツテト","sa shi su se so"]$json$::jsonb, $json$[{"id":"n5-katakana-s-t-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-s-t-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the rows and call attention to シ and ツ in one short English clarification.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-s-t-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-s-t-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-s-t-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-s-t-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read both rows and retry one difficult pair once more.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-s-t-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner finishes the katakana contrast mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-s-t-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-remaining-rows', 'japanese', 'jp-n5', 'Remaining katakana rows', 'Finish the remaining basic katakana rows so the learner owns the full 46-character system.', 'Full katakana chart ready', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Katakana Chart Complete', 20, $json$["Remaining rows","ン","Full 46-character chart"]$json$::jsonb, 'Mission 26: Complete the basic katakana chart', 'This mission closes the basic katakana chart and prepares you for real travel and food words.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 25)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-remaining-rows', 'japanese', 'jp-n5', 'n5-katakana-remaining-rows', 'Remaining katakana rows', 18, 'speaking', 'ナ ニ ヌ ネ ノ, ハ ヒ フ ヘ ホ, マ ミ ム メ モ, ヤ ユ ヨ, ラ リ ル レ ロ, ワ ヲ ン', 'Read the remaining katakana groups out loud.', 'full katakana chart', 'Learner can move through the rest of the katakana chart with real beginner confidence.', $json$["ナニヌネノ","ハヒフヘホ","ラリルレロ","ワヲン"]$json$::jsonb, $json$[{"id":"n5-katakana-remaining-rows-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-remaining-rows-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the remaining rows as the completion of a full beginner script map.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-remaining-rows-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-remaining-rows-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-remaining-rows-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-remaining-rows-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner for two full rows and one final-symbol group to close the chart.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-remaining-rows-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the full basic katakana chart.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-remaining-rows-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-loanwords', 'japanese', 'jp-n5', 'Starter katakana words', 'Teach common katakana words like hotel, bus, coffee, and taxi through friendly reading practice.', 'Katakana word mission', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Loanword Reader', 15, $json$["Travel words","Cafe words","Common imported vocabulary"]$json$::jsonb, 'Mission 27: Read travel and cafe words', 'Now the script starts paying off. You can read words you might actually hear on your first day in Japan.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 26)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-loanwords', 'japanese', 'jp-n5', 'n5-katakana-loanwords', 'Starter katakana words', 18, 'speaking', 'ホテル, バス, タクシー, コーヒー', 'Read hotel, bus, taxi, and coffee aloud in Japanese.', 'travel and cafe katakana', 'Learner can read useful katakana words instead of empty symbols.', $json$["ホテル","バス","タクシー","コーヒー","hoteru","takushii"]$json$::jsonb, $json$[{"id":"n5-katakana-loanwords-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-loanwords-model","label":"AI models the phrase","type":"ai_model","prompt":"Model travel and cafe words with natural Japanese rhythm so the learner hears them as living vocabulary.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-loanwords-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-loanwords-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-loanwords-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-loanwords-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read four practical words and identify which one means coffee.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-loanwords-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the first useful katakana word set.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-loanwords-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-names-countries', 'japanese', 'jp-n5', 'Names and country words', 'Teach country names and foreign-name style katakana so the learner hears how Japan adapts global words.', 'Name and country check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Global Katakana', 10, $json$["Country names","Foreign names","Identity in katakana"]$json$::jsonb, 'Mission 28: Read names from the wider world', 'India, America, and your own name sound different in Japanese. This mission makes that fun instead of strange.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 27)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-names-countries', 'japanese', 'jp-n5', 'n5-katakana-names-countries', 'Names and country words', 18, 'speaking', 'インド, アメリカ, ラフル', 'Say India, America, and Rahul in Japanese.', 'countries and names', 'Learner can say a few country and name words in Japanese katakana rhythm.', $json$["インド","アメリカ","ラフル","indo","amerika","rahuru"]$json$::jsonb, $json$[{"id":"n5-katakana-names-countries-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-names-countries-model","label":"AI models the phrase","type":"ai_model","prompt":"Model country and name words so the learner hears how Japanese reshapes global sounds.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-names-countries-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-names-countries-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-names-countries-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-names-countries-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the three words and notice how their own name changes in Japanese rhythm.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-names-countries-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the name and country mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-names-countries-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-dakuon', 'japanese', 'jp-n5', 'Katakana dakuon and handakuon', 'Teach ガ-row and パ-row style katakana sounds so modern vocabulary becomes clearer.', 'Voiced katakana check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Modern Sound Badge', 10, $json$["ガ-row","ザ-row","ダ-row","バ-row","パ-row"]$json$::jsonb, 'Mission 29: Add voiced modern sounds', 'Baggu and beddo do not work without voiced sounds. This mission brings modern Japanese pronunciation alive.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 28)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-dakuon', 'japanese', 'jp-n5', 'n5-katakana-dakuon', 'Katakana dakuon and handakuon', 18, 'repeat', 'ガ ギ グ ゲ ゴ, パ ピ プ ペ ポ', 'Repeat one voiced row and the pa-row clearly.', 'voiced katakana', 'Learner can repeat voiced katakana rows more accurately.', $json$["ガギグゲゴ","パピプペポ","ga gi gu ge go","pa pi pu pe po"]$json$::jsonb, $json$[{"id":"n5-katakana-dakuon-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-dakuon-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the voiced and pa sounds through practical words like baggu and pan.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-dakuon-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-dakuon-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-dakuon-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-dakuon-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat a voiced row and the pa-row once each.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-dakuon-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears voiced katakana practice.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-dakuon-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-yoon-long', 'japanese', 'jp-n5', 'Katakana yoon and long vowels', 'Teach combinations and long vowels in katakana so the learner can speak words like ジュース and チョコレート more naturally.', 'Katakana long-sound check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Long Sound Explorer', 15, $json$["ジュ","シャ","チョ","Long vowel mark ー","Modern word flow"]$json$::jsonb, 'Mission 30: Handle long modern word shapes', 'Modern words stretch, glide, and pause differently. This mission helps your ear catch that music.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 29)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-yoon-long', 'japanese', 'jp-n5', 'n5-katakana-yoon-long', 'Katakana yoon and long vowels', 18, 'repeat', 'ジュース, シャツ, チョコレート', 'Repeat juice, shirt, and chocolate in Japanese rhythm.', 'long vowels and combinations', 'Learner can repeat longer katakana words with stronger timing and clarity.', $json$["ジュース","シャツ","チョコレート","juusu","shatsu","chokoreeto"]$json$::jsonb, $json$[{"id":"n5-katakana-yoon-long-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-yoon-long-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the long-vowel mark and yoon combinations through familiar modern items.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-yoon-long-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-yoon-long-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-yoon-long-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-yoon-long-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the three words and retry the longest one once more.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-yoon-long-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the long-sound katakana mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-yoon-long-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-katakana-review', 'japanese', 'jp-n5', 'Full katakana practice', 'Review the full katakana chart and useful words so the learner feels stable before moving on.', 'Katakana mastery check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Katakana Explorer', 20, $json$["Full chart review","Common words","Voiced sounds","Long vowels"]$json$::jsonb, 'Mission 31: Lock in your katakana reading', 'This is your katakana consolidation mission, where modern Japanese words start to feel readable instead of decorative.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["katakana","special-kana","reading"],"vocabularyCategoryIds":["countries","drinks","transportation","travel-words"]}$json$::jsonb, 30)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-katakana-review', 'japanese', 'jp-n5', 'n5-katakana-review', 'Full katakana practice', 18, 'checkpoint', 'アイウエオ, カキクケコ, ホテル, コーヒー', 'Read one row and two useful katakana words aloud.', 'full katakana review', 'Learner leaves katakana with genuine reading confidence.', $json$["アイウエオ","カキクケコ","ホテル","コーヒー"]$json$::jsonb, $json$[{"id":"n5-katakana-review-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-review-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a compact but satisfying katakana review that feels like a real achievement.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-katakana-review-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-katakana-review-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-katakana-review-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-katakana-review-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read one row, one travel word, and one cafe word to finish the section.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-katakana-review-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner is ready to use katakana inside broader N5 Japanese.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-katakana-review-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-numbers-basics', 'japanese', 'jp-n5', 'Numbers 0 to 10', 'Teach the first Japanese numbers in English through voice practice and quick real-life prompts.', '0 to 10 count check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Number Ninja', 15, $json$["0 to 10","Alternative forms","Basic counting confidence"]$json$::jsonb, 'Mission 32: Count from zero', 'Prices, time, and age all begin here. This mission makes Japanese numbers feel approachable from the first ten.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["numbers","listening"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature"],"vocabularyCategoryIds":["numbers","money","time-expressions","weekdays","months-dates"]}$json$::jsonb, 31)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-numbers-basics', 'japanese', 'jp-n5', 'n5-numbers-basics', 'Numbers 0 to 10', 18, 'speaking', 'rei, ichi, ni, san, yon, go, roku, nana, hachi, kyuu, juu', 'Count from zero to ten clearly.', 'numbers 0 to 10', 'Learner can say the core beginner numbers aloud.', $json$["rei ichi ni san yon go roku nana hachi kyuu juu","いち に さん よん ご"]$json$::jsonb, $json$[{"id":"n5-numbers-basics-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-numbers-basics-model","label":"AI models the phrase","type":"ai_model","prompt":"Model zero to ten in a calm practical rhythm rather than a rushed chant.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-numbers-basics-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-numbers-basics-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-numbers-basics-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-numbers-basics-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to count to ten and retry four and seven once for confidence.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-numbers-basics-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the first number ladder.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-numbers-basics-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-numbers-teens-tens', 'japanese', 'jp-n5', 'Teens and tens', 'Teach 11 to 100 by showing the stacking pattern in clear English support.', 'Bigger number check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Count Builder', 15, $json$["11 to 20","30 to 90","Pattern stacking","21 and 99 examples"]$json$::jsonb, 'Mission 33: Build bigger numbers', 'Once you understand the pattern, bigger Japanese numbers suddenly stop looking scary.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["numbers","listening"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature"],"vocabularyCategoryIds":["numbers","money","time-expressions","weekdays","months-dates"]}$json$::jsonb, 32)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-numbers-teens-tens', 'japanese', 'jp-n5', 'n5-numbers-teens-tens', 'Teens and tens', 18, 'speaking', 'juuichi, juuni, nijuu, sanjuu, kyuujuukyuu', 'Say eleven, twenty, thirty-five, and ninety-nine.', 'teens and tens', 'Learner can form and speak larger beginner numbers.', $json$["juuichi","nijuu","sanjuugo","kyuujuukyuu","じゅういち","きゅうじゅうきゅう"]$json$::jsonb, $json$[{"id":"n5-numbers-teens-tens-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-numbers-teens-tens-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the Japanese stacking pattern so the learner hears the logic, not random memorization.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-numbers-teens-tens-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-numbers-teens-tens-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-numbers-teens-tens-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-numbers-teens-tens-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask for one teen number and two combined numbers, then repeat the hardest once.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-numbers-teens-tens-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner successfully forms bigger beginner numbers.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-numbers-teens-tens-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-money-age', 'japanese', 'jp-n5', 'Money and age', 'Teach yen amounts and age questions through practical English explanations and spoken drills.', 'Money and age check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Yen Counter', 15, $json$["Yen amounts","How much is it?","How old are you?","Age counters"]$json$::jsonb, 'Mission 34: Talk about prices and age', 'You buy something and someone asks how old you are. This mission prepares both moments.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["numbers","listening"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature"],"vocabularyCategoryIds":["numbers","money","time-expressions","weekdays","months-dates"]}$json$::jsonb, 33)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-money-age', 'japanese', 'jp-n5', 'n5-money-age', 'Money and age', 18, 'roleplay', 'hyaku en, sen en, nansai desu ka', 'Ask how much it is and then say twenty years old.', 'money and age', 'Learner can ask a price and answer or understand a simple age question.', $json$["ikura desu ka","hatachi","これは いくらですか","はたち"]$json$::jsonb, $json$[{"id":"n5-money-age-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-money-age-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a tiny shop exchange and a simple age answer with friendly pacing.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-money-age-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-money-age-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-money-age-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-money-age-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner one money line and one age line, then retry the harder one.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-money-age-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the money and age mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-money-age-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-time-weekdays', 'japanese', 'jp-n5', 'Time and weekdays', 'Teach clock time and weekdays so the learner can answer basic schedule questions in Japanese.', 'Time mission check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Schedule Starter', 10, $json$["What time is it?","1 to 10 o'clock","Weekdays","Schedule language"]$json$::jsonb, 'Mission 35: Tell time in Japan', 'Waking up at six and meeting on Monday are simple ideas, but saying them in Japanese feels like progress.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["numbers","listening"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature"],"vocabularyCategoryIds":["numbers","money","time-expressions","weekdays","months-dates"]}$json$::jsonb, 34)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-time-weekdays', 'japanese', 'jp-n5', 'n5-time-weekdays', 'Time and weekdays', 18, 'speaking', 'rokuji, getsuyoubi, nichiyoubi', 'Say six o''clock and Monday in Japanese.', 'time and weekdays', 'Learner can say a time and recognize or produce a weekday.', $json$["rokuji","getsuyoubi","ろくじ","げつようび"]$json$::jsonb, $json$[{"id":"n5-time-weekdays-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-time-weekdays-model","label":"AI models the phrase","type":"ai_model","prompt":"Model common time and weekday expressions in one small daily routine scene.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-time-weekdays-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-time-weekdays-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-time-weekdays-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-time-weekdays-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what time it is and what day it is, then repeat the answer smoothly.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-time-weekdays-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner can answer a small schedule prompt.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-time-weekdays-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-people-family', 'japanese', 'jp-n5', 'People and family words', 'Teach the first family and people words in English so the learner can describe close relationships.', 'People and family check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'People Builder', 10, $json$["I and you","Friend","Family","Mother and father","Brother and sister"]$json$::jsonb, 'Mission 36: Talk about people around you', 'The first meaningful vocabulary usually comes from the people you know. This mission turns that into Japanese.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["vocabulary","speaking"],"kanjiGroupIds":["kanji-people-relations"],"vocabularyCategoryIds":["people","family","jobs"]}$json$::jsonb, 35)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-people-family', 'japanese', 'jp-n5', 'n5-people-family', 'People and family words', 18, 'speaking', 'watashi, tomodachi, kazoku, haha, chichi', 'Say I, friend, family, mother, and father in Japanese.', 'people and family vocabulary', 'Learner can say a few basic people and family words clearly.', $json$["watashi","tomodachi","kazoku","haha","chichi","わたし","ともだち"]$json$::jsonb, $json$[{"id":"n5-people-family-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-people-family-model","label":"AI models the phrase","type":"ai_model","prompt":"Model family and people words with gentle real-life context instead of a flat list.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-people-family-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-people-family-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-people-family-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-people-family-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner who is in their family and have them answer with short word responses.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-people-family-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the first people vocabulary set.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-people-family-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-food-drink', 'japanese', 'jp-n5', 'Food and drink words', 'Teach food and drink words the learner will use in cafes, restaurants, and daily life.', 'Food vocabulary check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Menu Starter', 15, $json$["Water","Tea","Coffee","Rice","Bread","Sushi","Ramen","Fish","Meat","Vegetables"]$json$::jsonb, 'Mission 37: Build your first menu vocabulary', 'Water, tea, sushi, ramen, and bread are among the first Japanese words many learners truly use.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["vocabulary","speaking"],"vocabularyCategoryIds":["food","drinks","shopping-words"]}$json$::jsonb, 36)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-food-drink', 'japanese', 'jp-n5', 'n5-food-drink', 'Food and drink words', 18, 'speaking', 'mizu, ocha, sushi, raamen, pan', 'Say water, tea, sushi, ramen, and bread in Japanese.', 'food and drink vocabulary', 'Learner can say several core food and drink words with confidence.', $json$["mizu","ocha","sushi","raamen","pan","みず","おちゃ"]$json$::jsonb, $json$[{"id":"n5-food-drink-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-food-drink-model","label":"AI models the phrase","type":"ai_model","prompt":"Model menu vocabulary through a small cafe scene instead of a memorization list.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-food-drink-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-food-drink-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-food-drink-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-food-drink-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what they want to eat or drink and let them answer in short words first.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-food-drink-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner can use a useful beginner menu word bank.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-food-drink-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-places-objects', 'japanese', 'jp-n5', 'Places and objects', 'Teach house, school, station, shop, book, bag, phone, and similar daily words in spoken English-guided practice.', 'Places and objects check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Daily World Badge', 15, $json$["House","School","Station","Shop","Restaurant","Hotel","Book","Bag","Phone","Car"]$json$::jsonb, 'Mission 38: Name the places and things around you', 'You start seeing words for places and objects everywhere. This mission gives you the nouns that unlock daily scenes.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["vocabulary","reading"],"kanjiGroupIds":["kanji-directions-places","kanji-objects-environment"],"vocabularyCategoryIds":["places","buildings","everyday-objects"]}$json$::jsonb, 37)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-places-objects', 'japanese', 'jp-n5', 'n5-places-objects', 'Places and objects', 18, 'speaking', 'ie, gakkou, eki, hon, kaban, denwa', 'Say house, school, station, book, bag, and phone in Japanese.', 'daily nouns', 'Learner can say and recognize common places and objects.', $json$["ie","gakkou","eki","hon","kaban","denwa","いえ","えき"]$json$::jsonb, $json$[{"id":"n5-places-objects-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-places-objects-model","label":"AI models the phrase","type":"ai_model","prompt":"Model daily nouns as things you carry and places you visit in a single day.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-places-objects-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-places-objects-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-places-objects-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-places-objects-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what they have and where they are going using short noun answers.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-places-objects-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the places and objects mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-places-objects-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-weather-colors', 'japanese', 'jp-n5', 'Weather and colors', 'Teach weather and color basics so the learner can start describing what the day feels like.', 'Description starter', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Description Spark', 10, $json$["Sunny","Rain","Snow","Hot","Cold","White","New","Old"]$json$::jsonb, 'Mission 39: Describe simple everyday things', 'Sunny, rainy, hot, cold, white, and new are small words, but they make Japanese feel much more alive.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 38)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-weather-colors', 'japanese', 'jp-n5', 'n5-weather-colors', 'Weather and colors', 18, 'speaking', 'hare, ame, atsui, samui, shiroi', 'Say sunny, rain, hot, cold, and white in Japanese.', 'simple description vocabulary', 'Learner can describe simple weather or item qualities in basic Japanese.', $json$["hare","ame","atsui","samui","shiroi","はれ","あめ"]$json$::jsonb, $json$[{"id":"n5-weather-colors-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-weather-colors-model","label":"AI models the phrase","type":"ai_model","prompt":"Model weather and color words like small observations a traveler would naturally say.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-weather-colors-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-weather-colors-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-weather-colors-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-weather-colors-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner how the weather is and what color something is, then repeat key words.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-weather-colors-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner begins describing the world in Japanese.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-weather-colors-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-greetings-polite', 'japanese', 'jp-n5', 'Greetings and polite words', 'Teach the most important greetings and polite words in English-led practice so the learner sounds warm and safe.', 'Greeting confidence check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Politeness Badge', 15, $json$["Good morning","Hello","Good evening","Thank you","Excuse me","Please","You're welcome"]$json$::jsonb, 'Mission 40: Sound respectful from the start', 'A good greeting changes the whole interaction. This mission helps you sound human and respectful immediately.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["vocabulary","speaking"],"vocabularyCategoryIds":["greetings","basic-expressions","question-words"]}$json$::jsonb, 39)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-greetings-polite', 'japanese', 'jp-n5', 'n5-greetings-polite', 'Greetings and polite words', 18, 'roleplay', 'ohayou gozaimasu, konnichiwa, arigatou gozaimasu, sumimasen', 'Say good morning, thank you, and excuse me in Japanese.', 'greetings and politeness', 'Learner can greet, thank, and sound polite in a short exchange.', $json$["ohayou gozaimasu","arigatou gozaimasu","sumimasen","おはようございます","ありがとうございます"]$json$::jsonb, $json$[{"id":"n5-greetings-polite-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-greetings-polite-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a friendly greeting exchange that a learner could actually use on day one in Japan.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-greetings-polite-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-greetings-polite-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-greetings-polite-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-greetings-polite-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Roleplay a tiny greeting moment and have the learner respond politely.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-greetings-polite-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner can open and soften a conversation with polite Japanese.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-greetings-polite-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-survival-phrases', 'japanese', 'jp-n5', 'Survival phrases', 'Teach the beginner repair phrases that help the learner slow things down or ask for help.', 'Survival phrase check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Survival Speaker', 15, $json$["I don't understand","One more time please","Slowly please","Do you understand English?","Please help me"]$json$::jsonb, 'Mission 41: Rescue the conversation', 'You do not need perfect Japanese to survive. You need a few rescue phrases that keep you calm and understood.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["vocabulary","speaking"],"vocabularyCategoryIds":["greetings","basic-expressions","question-words"]}$json$::jsonb, 40)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-survival-phrases', 'japanese', 'jp-n5', 'n5-survival-phrases', 'Survival phrases', 18, 'roleplay', 'wakarimasen, mou ichido onegaishimasu, yukkuri onegaishimasu', 'Say I do not understand and one more time please.', 'repair phrases', 'Learner can recover from confusion without giving up.', $json$["wakarimasen","mou ichido onegaishimasu","わかりません","もういちど おねがいします"]$json$::jsonb, $json$[{"id":"n5-survival-phrases-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-survival-phrases-model","label":"AI models the phrase","type":"ai_model","prompt":"Model rescue phrases with reassuring tone so the learner feels empowered, not embarrassed.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-survival-phrases-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-survival-phrases-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-survival-phrases-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-survival-phrases-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Pretend the tutor spoke too fast and ask the learner to request help using the target phrases.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-survival-phrases-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the survival-language mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-survival-phrases-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-first-sentences', 'japanese', 'jp-n5', 'First sentence pattern', 'Teach A は B です through English explanation and voice-first practice so the learner forms real sentences.', 'Sentence pattern check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Sentence Starter', 20, $json$["I am ...","This is ...","That place is ...","Polite sentence ending"]$json$::jsonb, 'Mission 42: Build complete beginner sentences', 'This is the moment Japanese becomes a sentence language instead of a pile of words.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["particles","grammar","speaking"],"vocabularyCategoryIds":["question-words","basic-expressions","people"]}$json$::jsonb, 41)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-first-sentences', 'japanese', 'jp-n5', 'n5-first-sentences', 'First sentence pattern', 18, 'speaking', 'watashi wa Rahul desu. kore wa hon desu.', 'Say I am Rahul and this is a book.', 'A wa B desu', 'Learner can produce short complete beginner sentences.', $json$["watashi wa rahul desu","kore wa hon desu","わたしは ラフルです","これは ほんです"]$json$::jsonb, $json$[{"id":"n5-first-sentences-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-first-sentences-model","label":"AI models the phrase","type":"ai_model","prompt":"Model one self-introduction sentence and one object sentence as the learner's first real grammar win.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-first-sentences-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-first-sentences-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-first-sentences-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-first-sentences-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to use the pattern for self and for one object, then repeat it more naturally.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-first-sentences-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner produces two full beginner sentences.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-first-sentences-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-questions-answers', 'japanese', 'jp-n5', 'Questions and answers', 'Teach A は B ですか and the core yes-no answers so the learner can ask and respond simply.', 'Question loop check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Question Spark', 15, $json$["Is this...?","Yes that is right","No that is different","Question rhythm"]$json$::jsonb, 'Mission 43: Make conversation move both ways', 'Now conversation becomes two-way. This mission adds the first real question and answer loop.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["particles","grammar","speaking"],"vocabularyCategoryIds":["question-words","basic-expressions","people"]}$json$::jsonb, 42)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-questions-answers', 'japanese', 'jp-n5', 'n5-questions-answers', 'Questions and answers', 18, 'roleplay', 'kore wa hon desu ka. hai, sou desu. iie, chigaimasu.', 'Ask if this is a book, answer yes once, then answer no once.', 'basic question and answer', 'Learner can ask and answer a simple beginner question.', $json$["kore wa hon desu ka","hai sou desu","iie chigaimasu","これは ほんですか"]$json$::jsonb, $json$[{"id":"n5-questions-answers-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-questions-answers-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the question loop with a small pause so the learner hears the shape of beginner conversation.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-questions-answers-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-questions-answers-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-questions-answers-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-questions-answers-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask one yes-no question and have the learner respond both positively and negatively.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-questions-answers-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the first question-answer loop.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-questions-answers-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-particles-basic', 'japanese', 'jp-n5', 'Core particles 1', 'Teach は, が, を, and に in clear English so the learner starts hearing what holds Japanese sentences together.', 'Particle basics check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Particle Master', 20, $json$["は topic","が subject","を object","に destination and time"]$json$::jsonb, 'Mission 44: Make sentences click', 'Particles are tiny, but once you feel them, Japanese begins to make much more sense.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["particles","grammar"],"vocabularyCategoryIds":["basic-expressions","direction-words","places"]}$json$::jsonb, 43)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-particles-basic', 'japanese', 'jp-n5', 'n5-particles-basic', 'Core particles 1', 18, 'speaking', 'watashi wa Rahul desu. mizu o nomimasu. gakkou ni ikimasu.', 'Say I am Rahul, I drink water, and I go to school.', 'basic particles', 'Learner can use the most basic particles in practical lines.', $json$["watashi wa rahul desu","mizu o nomimasu","gakkou ni ikimasu","みずをのみます"]$json$::jsonb, $json$[{"id":"n5-particles-basic-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-particles-basic-model","label":"AI models the phrase","type":"ai_model","prompt":"Model practical particle sentences and explain only the minimal English needed to keep speaking moving.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-particles-basic-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-particles-basic-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-particles-basic-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-particles-basic-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask for one self sentence, one object sentence, and one destination sentence.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-particles-basic-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the core particle mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-particles-basic-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-particles-extended', 'japanese', 'jp-n5', 'Core particles 2', 'Teach で, と, も, の, から, まで, か, ね, and よ through simple spoken examples in English.', 'Extended particle check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Particle Builder', 15, $json$["で","と","も","の","から","まで","か","ね","よ"]$json$::jsonb, 'Mission 45: Add relationship and nuance particles', 'Now you begin linking places, people, possession, and soft conversation tone together like a real beginner speaker.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["particles","grammar"],"vocabularyCategoryIds":["basic-expressions","direction-words","places"]}$json$::jsonb, 44)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-particles-extended', 'japanese', 'jp-n5', 'n5-particles-extended', 'Core particles 2', 18, 'speaking', 'resutoran de tabemasu. watashi no hon. tomodachi to ikimasu.', 'Say I eat at a restaurant, my book, and I go with a friend.', 'extended particle use', 'Learner can notice and use more relationship particles inside practical Japanese.', $json$["resutoran de tabemasu","watashi no hon","tomodachi to ikimasu","レストランでたべます"]$json$::jsonb, $json$[{"id":"n5-particles-extended-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-particles-extended-model","label":"AI models the phrase","type":"ai_model","prompt":"Model relationship particles inside useful travel and daily-life lines rather than abstract grammar talk.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-particles-extended-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-particles-extended-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-particles-extended-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-particles-extended-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask for one place sentence, one possession sentence, and one with-a-friend sentence.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-particles-extended-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the extended particle mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-particles-extended-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-verbs-basic', 'japanese', 'jp-n5', 'Verb basics', 'Teach the core N5 polite verbs so the learner can talk about eating, drinking, going, seeing, and studying.', 'Verb basics check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Action Starter', 20, $json$["Eat","Drink","Go","Come","See","Read","Write","Study","Work"]$json$::jsonb, 'Mission 46: Speak with action words', 'Once verbs arrive, Japanese suddenly feels much more alive and personal.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["verbs-adjectives","grammar"],"vocabularyCategoryIds":["basic-verbs","basic-adjectives","common-adverbs"]}$json$::jsonb, 45)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-verbs-basic', 'japanese', 'jp-n5', 'n5-verbs-basic', 'Verb basics', 18, 'speaking', 'tabemasu, nomimasu, ikimasu, mimasu, benkyou shimasu', 'Say eat, drink, go, see, and study in Japanese.', 'polite verb basics', 'Learner can say the most useful beginner actions in polite form.', $json$["tabemasu","nomimasu","ikimasu","mimasu","benkyou shimasu","たべます"]$json$::jsonb, $json$[{"id":"n5-verbs-basic-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-verbs-basic-model","label":"AI models the phrase","type":"ai_model","prompt":"Model daily-life verbs as actions a real learner might do throughout the day.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-verbs-basic-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-verbs-basic-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-verbs-basic-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-verbs-basic-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what they eat, drink, or study using single-verb replies first.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-verbs-basic-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the core verb mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-verbs-basic-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-verb-forms', 'japanese', 'jp-n5', 'Verb forms', 'Teach the basic polite, negative, past, dictionary, nai, ta, and te forms through English support and repeated speech.', 'Verb form mission', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Verb Shape Badge', 20, $json$["Polite present","Polite negative","Polite past","Dictionary form","Nai","Ta","Te"]$json$::jsonb, 'Mission 47: Hear verbs change shape', 'Japanese verbs bend in ways that look strange at first, but this mission helps your ear settle into the pattern.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["verbs-adjectives","grammar"],"vocabularyCategoryIds":["basic-verbs","basic-adjectives","common-adverbs"]}$json$::jsonb, 46)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-verb-forms', 'japanese', 'jp-n5', 'n5-verb-forms', 'Verb forms', 18, 'listening', 'tabemasu, tabemasen, tabemashita, tabenai, tabete, tabeta', 'Repeat the forms for eat from polite present through ta-form.', 'verb form awareness', 'Learner recognizes how a verb changes shape across useful beginner forms.', $json$["tabemasu","tabemasen","tabemashita","tabenai","tabete","tabeta","たべます"]$json$::jsonb, $json$[{"id":"n5-verb-forms-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-verb-forms-model","label":"AI models the phrase","type":"ai_model","prompt":"Model one core verb through several shapes so the learner hears the form family, not random fragments.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-verb-forms-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-verb-forms-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-verb-forms-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-verb-forms-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to repeat the forms and identify which one sounds like the past.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-verb-forms-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the basic verb-form mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-verb-forms-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-adjectives', 'japanese', 'jp-n5', 'Adjectives', 'Teach common い-adjectives and な-adjectives in English through practical spoken Japanese.', 'Adjective mission', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Description Starter', 20, $json$["い-adjectives","な-adjectives","Positive","Negative","Past forms"]$json$::jsonb, 'Mission 48: Describe food, weather, and places', 'Now you can say what is delicious, quiet, beautiful, cheap, cold, or convenient.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["verbs-adjectives","grammar"],"vocabularyCategoryIds":["basic-verbs","basic-adjectives","common-adverbs"]}$json$::jsonb, 47)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-adjectives', 'japanese', 'jp-n5', 'n5-adjectives', 'Adjectives', 18, 'speaking', 'oishii desu. samui desu. shizuka desu. kirei desu.', 'Say it is delicious, cold, quiet, and beautiful.', 'i and na adjectives', 'Learner can describe simple things with more personality.', $json$["oishii desu","samui desu","shizuka desu","kirei desu","おいしいです"]$json$::jsonb, $json$[{"id":"n5-adjectives-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-adjectives-model","label":"AI models the phrase","type":"ai_model","prompt":"Model simple descriptive lines tied to food, weather, and rooms rather than abstract explanation.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-adjectives-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-adjectives-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-adjectives-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-adjectives-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner how the food is and how the room is, then retry one adjective naturally.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-adjectives-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the adjective mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-adjectives-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-grammar-patterns-1', 'japanese', 'jp-n5', 'Grammar patterns 1', 'Teach early N5 patterns like てください, てもいいです, and てはいけません in English-led spoken practice.', 'Pattern set one', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Grammar Starter', 20, $json$["〜てください","〜てもいいです","〜てはいけません","〜ています"]$json$::jsonb, 'Mission 49: Make requests and permissions', 'Requests and permissions are everywhere in real life. This mission makes those sentence patterns usable.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 48)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-grammar-patterns-1', 'japanese', 'jp-n5', 'n5-grammar-patterns-1', 'Grammar patterns 1', 18, 'roleplay', 'mizu o nonde kudasai. koko de suwatte mo ii desu. koko de tabete wa ikemasen.', 'Say please drink water and you may sit here.', 'request and permission patterns', 'Learner can repeat and use a few important request and permission patterns.', $json$["nonde kudasai","suwatte mo ii desu","のんでください","すわってもいいです"]$json$::jsonb, $json$[{"id":"n5-grammar-patterns-1-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-grammar-patterns-1-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the patterns as short real-life lines that a traveler could actually hear and use.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-grammar-patterns-1-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-grammar-patterns-1-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-grammar-patterns-1-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-grammar-patterns-1-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to request one action and give one permission response.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-grammar-patterns-1-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the first grammar-pattern set.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-grammar-patterns-1-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-grammar-patterns-2', 'japanese', 'jp-n5', 'Grammar patterns 2', 'Teach more N5 patterns like たいです, がほしいです, から, つもりです, and とおもいます through spoken examples.', 'Pattern set two', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Pattern Builder', 20, $json$["〜たいです","〜がほしいです","〜から","〜つもりです","〜とおもいます"]$json$::jsonb, 'Mission 50: Talk about wants, plans, and reasons', 'Now your Japanese can express want, intention, and opinion instead of only facts.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 49)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-grammar-patterns-2', 'japanese', 'jp-n5', 'n5-grammar-patterns-2', 'Grammar patterns 2', 18, 'roleplay', 'nihon e ikitai desu. mizu ga hoshii desu. atsui desu kara mizu o nomimasu.', 'Say I want to go to Japan and I want water.', 'wants and reasons', 'Learner can express desire, reason, and simple intention more clearly.', $json$["nihon e ikitai desu","mizu ga hoshii desu","にほんへ いきたいです","みずが ほしいです"]$json$::jsonb, $json$[{"id":"n5-grammar-patterns-2-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-grammar-patterns-2-model","label":"AI models the phrase","type":"ai_model","prompt":"Model want and reason patterns through goals a beginner genuinely has.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-grammar-patterns-2-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-grammar-patterns-2-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-grammar-patterns-2-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-grammar-patterns-2-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner what they want and why, then have them answer in short lines.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-grammar-patterns-2-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the second grammar-pattern mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-grammar-patterns-2-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-counters', 'japanese', 'jp-n5', 'Counters', 'Teach general items, people, books, machines, floors, times, and small animals through English-guided speaking drills.', 'Counter mission', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Counter Captain', 20, $json$["〜つ","〜人","〜冊","〜台","〜回","〜階","〜歳","〜匹"]$json$::jsonb, 'Mission 51: Count the Japanese way', 'In Japanese, the way you count depends on what you count. This mission makes that system feel usable.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["counters","numbers"],"vocabularyCategoryIds":["numbers","money","people","everyday-objects"]}$json$::jsonb, 50)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-counters', 'japanese', 'jp-n5', 'n5-counters', 'Counters', 18, 'speaking', 'hitotsu, futatsu, hitori, futari, issatsu, ikkai', 'Say one thing, two things, one person, two people, one book, and one time.', 'basic counters', 'Learner can answer simple counting prompts more naturally.', $json$["hitotsu","futatsu","hitori","futari","issatsu","ikkai","ひとつ"]$json$::jsonb, $json$[{"id":"n5-counters-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-counters-model","label":"AI models the phrase","type":"ai_model","prompt":"Model counters in everyday shopping, people, and schedule situations.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-counters-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-counters-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-counters-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-counters-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask how many people, books, or times and let the learner answer in short counter phrases.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-counters-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the counter mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-counters-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-kanji-foundation-1', 'japanese', 'jp-n5', 'Kanji foundation 1', 'Teach essential N5 kanji in English by grouping them into numbers, time, and directions before full overload happens.', 'Kanji group check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Kanji Starter', 20, $json$["Numbers and money","Time and dates","Directions","Everyday kanji words"]$json$::jsonb, 'Mission 52: Read core kanji groups', 'Kanji becomes much less scary when you meet it in useful groups instead of random lists.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["kanji","reading"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature","kanji-directions-places","kanji-people-relations","kanji-actions","kanji-objects-environment"],"vocabularyCategoryIds":["numbers","places","basic-verbs"]}$json$::jsonb, 51)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-kanji-foundation-1', 'japanese', 'jp-n5', 'n5-kanji-foundation-1', 'Kanji foundation 1', 18, 'listening', '日本, 学生, 先生, 駅, 日, 月, 火, 水', 'Read Japan, student, teacher, station, day, month, fire, and water aloud.', 'starter kanji recognition', 'Learner can recognize and say some of the most important N5 kanji items.', $json$["nihon","gakusei","sensei","eki","日","月","日本","学生"]$json$::jsonb, $json$[{"id":"n5-kanji-foundation-1-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-kanji-foundation-1-model","label":"AI models the phrase","type":"ai_model","prompt":"Model kanji words in useful beginner contexts so symbols arrive with meaning.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-kanji-foundation-1-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-kanji-foundation-1-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-kanji-foundation-1-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-kanji-foundation-1-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read each word and then tell which one means station.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-kanji-foundation-1-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the first essential kanji group.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-kanji-foundation-1-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-kanji-foundation-2', 'japanese', 'jp-n5', 'Kanji foundation 2', 'Continue teaching N5 kanji through people, verbs, and common object categories in spoken English guidance.', 'Kanji group two', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Kanji Builder', 20, $json$["People and family kanji","Basic action kanji","Object and environment kanji","Toward the 103 essential set"]$json$::jsonb, 'Mission 53: Expand into people, actions, and objects', 'The next kanji set connects directly to daily life: people, action, and objects you meet often.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["kanji","reading"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature","kanji-directions-places","kanji-people-relations","kanji-actions","kanji-objects-environment"],"vocabularyCategoryIds":["numbers","places","basic-verbs"]}$json$::jsonb, 52)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-kanji-foundation-2', 'japanese', 'jp-n5', 'n5-kanji-foundation-2', 'Kanji foundation 2', 18, 'listening', '人, 子, 父, 母, 行, 来, 食, 飲, 本, 車', 'Read person, child, father, mother, go, come, eat, drink, book, and car aloud.', 'extended kanji recognition', 'Learner can recognize more of the essential N5 kanji foundation.', $json$["hito","ko","chichi","haha","iku","kuru","hon","kuruma"]$json$::jsonb, $json$[{"id":"n5-kanji-foundation-2-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-kanji-foundation-2-model","label":"AI models the phrase","type":"ai_model","prompt":"Model essential kanji through core words the learner already knows by sound.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-kanji-foundation-2-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-kanji-foundation-2-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-kanji-foundation-2-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-kanji-foundation-2-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to read a few kanji items and connect each to a familiar spoken word.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-kanji-foundation-2-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the second kanji foundation mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-kanji-foundation-2-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-self-introduction', 'japanese', 'jp-n5', 'Self introduction', 'Teach a complete beginner self-introduction in English and spoken Japanese through a guided roleplay.', 'Self introduction roleplay', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'First Conversation Badge', 20, $json$["Nice to meet you","My name is","I came from","Job or identity line","Polite close"]$json$::jsonb, 'Mission 54: Meet Yuki in Japanese', 'Yuki meets you for the first time and waits for your introduction. This mission helps you answer warmly and clearly.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 53)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-self-introduction', 'japanese', 'jp-n5', 'n5-self-introduction', 'Self introduction', 18, 'roleplay', 'hajimemashite. watashi wa Rahul desu. Indo kara kimashita. yoroshiku onegaishimasu.', 'Introduce yourself, say where you are from, and end politely.', 'first meeting conversation', 'Learner can introduce themselves in a complete short roleplay.', $json$["hajimemashite","watashi wa rahul desu","indo kara kimashita","yoroshiku onegaishimasu"]$json$::jsonb, $json$[{"id":"n5-self-introduction-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-self-introduction-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a complete first-meeting exchange that sounds achievable for a beginner.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-self-introduction-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-self-introduction-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-self-introduction-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-self-introduction-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Roleplay Yuki meeting the learner and ask for name, country, and one identity detail.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-self-introduction-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the self-introduction mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-self-introduction-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-cafe-restaurant', 'japanese', 'jp-n5', 'Cafe and restaurant', 'Teach the learner to order food and drink politely in English-supported spoken Japanese.', 'Food roleplay check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Food Mission Badge', 20, $json$["Excuse me","Water please","Food ordering","How much is this?","It is delicious"]$json$::jsonb, 'Mission 55: Order food with Sakura', 'Sakura is working behind the counter. This mission teaches you how to ask for water, ramen, and the price.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["vocabulary","speaking"],"vocabularyCategoryIds":["food","drinks","shopping-words"]}$json$::jsonb, 54)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-cafe-restaurant', 'japanese', 'jp-n5', 'n5-cafe-restaurant', 'Cafe and restaurant', 18, 'roleplay', 'sumimasen. mizu o kudasai. raamen o kudasai. kore wa ikura desu ka.', 'Ask for water, ask for ramen, and ask how much it is.', 'ordering at a cafe or restaurant', 'Learner can handle a short food-ordering roleplay.', $json$["sumimasen","mizu o kudasai","raamen o kudasai","ikura desu ka","みずをください"]$json$::jsonb, $json$[{"id":"n5-cafe-restaurant-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-cafe-restaurant-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a small but realistic order flow in a Japanese cafe or restaurant.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-cafe-restaurant-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-cafe-restaurant-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-cafe-restaurant-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-cafe-restaurant-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Let Sakura ask what the learner wants and coach them through the order and price question.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-cafe-restaurant-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the cafe mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-cafe-restaurant-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-directions', 'japanese', 'jp-n5', 'Directions', 'Teach the learner to ask for a station and understand basic direction language in a guided roleplay.', 'Direction roleplay check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Direction Master', 20, $json$["Where is the station?","Straight ahead","Right","Thank you","Polite asking"]$json$::jsonb, 'Mission 56: Ask Hiro for the station', 'You are lost for a moment in the city, and Hiro is the helper who can point you toward the station.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["speaking","listening"],"kanjiGroupIds":["kanji-directions-places"],"vocabularyCategoryIds":["direction-words","places","travel-words"]}$json$::jsonb, 55)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-directions', 'japanese', 'jp-n5', 'n5-directions', 'Directions', 18, 'roleplay', 'sumimasen. eki wa doko desu ka. massugu desu. migi desu.', 'Ask where the station is and say it is on the right.', 'direction and location conversation', 'Learner can ask where the station is and respond to a simple direction answer.', $json$["eki wa doko desu ka","migi desu","massugu desu","えきは どこですか"]$json$::jsonb, $json$[{"id":"n5-directions-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-directions-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a city-help exchange where the learner has one urgent, useful question.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-directions-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-directions-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-directions-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-directions-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Let Hiro answer once, then ask the learner to repeat the direction and the question.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-directions-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the direction mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-directions-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-shopping', 'japanese', 'jp-n5', 'Shopping', 'Teach a short shopping conversation in spoken Japanese through English guidance and practical roleplay.', 'Shopping roleplay check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Shopping Samurai', 20, $json$["How much is this?","It is 1000 yen","I will take this","Is card okay?"]$json$::jsonb, 'Mission 57: Buy something from Tanaka-san', 'Tanaka-san is ready at the shop counter. This mission teaches you to ask the price and make the purchase.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["numbers","speaking","vocabulary"],"vocabularyCategoryIds":["shopping-words","money","everyday-objects"]}$json$::jsonb, 56)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-shopping', 'japanese', 'jp-n5', 'n5-shopping', 'Shopping', 18, 'roleplay', 'kore wa ikura desu ka. sen en desu. kore o kudasai. kaado wa daijoubu desu ka.', 'Ask how much it is, say you will take it, and ask if card is okay.', 'shopping conversation', 'Learner can complete a short shopping exchange with price and payment.', $json$["ikura desu ka","kore o kudasai","kaado wa daijoubu desu ka","これをください"]$json$::jsonb, $json$[{"id":"n5-shopping-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-shopping-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a natural shop counter exchange that feels directly useful to a traveler.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-shopping-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-shopping-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-shopping-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-shopping-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Let Tanaka-san offer the price and ask the learner to complete the purchase politely.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-shopping-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the shopping mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-shopping-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-daily-routine', 'japanese', 'jp-n5', 'Daily routine', 'Teach the learner to talk about waking up, eating breakfast, and studying through a simple routine conversation.', 'Routine roleplay check', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Daily Flow Badge', 15, $json$["Wake-up time","Breakfast","Study routine","Simple habit sequence"]$json$::jsonb, 'Mission 58: Describe your day in Japanese', 'Real language lives in daily habits. This mission helps you describe what your day actually looks like.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["speaking","grammar"],"vocabularyCategoryIds":["time-expressions","basic-verbs","house-words"]}$json$::jsonb, 57)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-daily-routine', 'japanese', 'jp-n5', 'n5-daily-routine', 'Daily routine', 18, 'speaking', 'rokuji ni okimasu. asagohan o tabemasu. nihongo o benkyou shimasu.', 'Say what time you wake up, that you eat breakfast, and that you study Japanese.', 'daily routine conversation', 'Learner can speak about a basic daily routine in short lines.', $json$["rokuji ni okimasu","asagohan o tabemasu","nihongo o benkyou shimasu","ろくじに おきます"]$json$::jsonb, $json$[{"id":"n5-daily-routine-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-daily-routine-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a short morning routine that feels realistic and achievable.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-daily-routine-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-daily-routine-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-daily-routine-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-daily-routine-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner for the time they wake up and one or two daily actions.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-daily-routine-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the daily routine mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-daily-routine-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-listening-practice', 'japanese', 'jp-n5', 'Listening practice', 'Cover the listening side of the course with guided phrase, number, word, and mini-conversation listening tasks explained in English.', 'Listening challenge', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Listening Ladder', 20, $json$["Vowels","Kana sounds","Words","Numbers","Sentences","Mini conversations"]$json$::jsonb, 'Mission 59: Train your ear for N5 Japanese', 'Now the language must arrive through your ears, not just your eyes. This mission turns hearing into a real skill.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["listening","reading"],"vocabularyCategoryIds":["basic-expressions","numbers","greetings"]}$json$::jsonb, 58)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-listening-practice', 'japanese', 'jp-n5', 'n5-listening-practice', 'Listening practice', 18, 'listening', 'arigatou gozaimasu. rokuji. mizu o kudasai. kore wa hon desu.', 'Repeat what you hear and answer one small listening prompt.', 'mixed listening review', 'Learner can catch beginner Japanese by ear with more confidence.', $json$["arigatou gozaimasu","rokuji","mizu o kudasai","ありがとうございます"]$json$::jsonb, $json$[{"id":"n5-listening-practice-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-listening-practice-model","label":"AI models the phrase","type":"ai_model","prompt":"Model small listening moments across the whole N5 course, keeping the learner active rather than passive.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-listening-practice-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-listening-practice-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-listening-practice-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-listening-practice-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to hear, repeat, and then answer one small meaning or response question.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-listening-practice-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the listening practice mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-listening-practice-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-speaking-practice', 'japanese', 'jp-n5', 'Speaking practice', 'Pull together vowels, kana, words, roleplays, and AI question answering into a broad speaking mission.', 'Speaking challenge', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Speaking Climber', 25, $json$["Repeat sounds","Read words aloud","Introduce yourself","Order food","Ask directions","Answer AI prompts"]$json$::jsonb, 'Mission 60: Speak across the whole N5 path', 'This is where all the pieces begin acting like one real language instead of separate study topics.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","vocabulary","speaking"],"vocabularyCategoryIds":["greetings","numbers","basic-expressions"]}$json$::jsonb, 59)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-speaking-practice', 'japanese', 'jp-n5', 'n5-speaking-practice', 'Speaking practice', 18, 'checkpoint', 'watashi wa Rahul desu. mizu o kudasai. eki wa doko desu ka.', 'Introduce yourself, order one thing, and ask for the station.', 'integrated speaking review', 'Learner can use Japanese across several beginner situations in one session.', $json$["watashi wa rahul desu","mizu o kudasai","eki wa doko desu ka","わたしは ラフルです"]$json$::jsonb, $json$[{"id":"n5-speaking-practice-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-speaking-practice-model","label":"AI models the phrase","type":"ai_model","prompt":"Model a broad but learner-safe speaking loop that proves the course is becoming real skill.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-speaking-practice-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-speaking-practice-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-speaking-practice-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-speaking-practice-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask three practical prompts in sequence and coach the learner through one smoother retry.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-speaking-practice-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner clears the integrated speaking mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-speaking-practice-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-reading-practice', 'japanese', 'jp-n5', 'Reading practice', 'Review the full reading path from single hiragana through short paragraphs using English support and voice output.', 'Reading ladder challenge', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'Reading Ranger', 20, $json$["Single hiragana","Hiragana words","Katakana words","Kanji words","Short sentences","Tiny paragraph"]$json$::jsonb, 'Mission 61: Climb the N5 reading ladder', 'You started with one row of sounds, and now you can read full beginner lines. This mission proves that growth clearly.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["reading","kanji"],"kanjiGroupIds":["kanji-objects-environment","kanji-people-relations"],"vocabularyCategoryIds":["greetings","travel-words","question-words"]}$json$::jsonb, 60)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-reading-practice', 'japanese', 'jp-n5', 'n5-reading-practice', 'Reading practice', 18, 'listening', 'あ, ねこ, ホテル, 日本, これは ほんです。 わたしは ラフルです。', 'Read one symbol, one word, one katakana word, one kanji word, and one short sentence aloud.', 'integrated reading review', 'Learner can read across the full beginner script ladder with stronger calm.', $json$["あ","ねこ","ホテル","日本","これは ほんです"]$json$::jsonb, $json$[{"id":"n5-reading-practice-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-reading-practice-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the full reading ladder from simplest to richest so the learner hears how far they have come.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-reading-practice-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-reading-practice-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-reading-practice-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-reading-practice-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner to climb the ladder one piece at a time and retry the hardest rung once.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-reading-practice-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Learner completes the reading ladder mission.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-reading-practice-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('n5-review-and-final-exam', 'japanese', 'jp-n5', 'Review and final N5 certificate exam', 'Review the full course and run the final integrated N5 certificate exam in English-guided spoken Japanese.', 'N5 certificate gate', 'Use short native-language rescue notes only when they help the learner return to speaking faster.', 'not_started', 'N5 Champion', 100, $json$["Sounds","Hiragana","Katakana","Numbers","Vocabulary","Particles","Verb forms","Adjectives","Grammar","Counters","Kanji","Listening","Reading","Speaking roleplays"]$json$::jsonb, 'Final Mission: Clear the N5 challenge', 'Everything now comes together: sounds, kana, words, grammar, reading, listening, and practical roleplay. This is the final gate.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${"examSectionIds":["sounds-romaji","hiragana","katakana","special-kana","numbers","vocabulary","particles","verbs-adjectives","grammar","counters","kanji","listening","reading","speaking"],"kanjiGroupIds":["kanji-numbers-money","kanji-time-nature","kanji-directions-places","kanji-people-relations","kanji-actions","kanji-objects-environment"],"vocabularyCategoryIds":["greetings","classroom-japanese","time-expressions","weekdays","months-dates","numbers","money","family","people","jobs","countries","languages","food","drinks","places","buildings","transportation","everyday-objects","clothing","weather","nature","body-parts","colors","basic-verbs","basic-adjectives","shopping-words","direction-words","school-words","house-words","travel-words","question-words","common-adverbs","basic-expressions"]}$json$::jsonb, 61)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('n5-review-and-final-exam', 'japanese', 'jp-n5', 'n5-review-and-final-exam', 'Review and final N5 certificate exam', 18, 'checkpoint', 'hajimemashite. watashi wa Rahul desu. mizu o kudasai. eki wa doko desu ka.', 'Complete the guided exam with a greeting, self-introduction, practical request, and direction question.', 'final N5 exam', 'Learner proves they can finish the platform N5 journey and qualify for the certificate.', $json$["hajimemashite","watashi wa rahul desu","mizu o kudasai","eki wa doko desu ka","はじめまして"]$json$::jsonb, $json$[{"id":"n5-review-and-final-exam-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-review-and-final-exam-model","label":"AI models the phrase","type":"ai_model","prompt":"Model the full final mission once so the learner hears the target level for certificate completion.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"n5-review-and-final-exam-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"n5-review-and-final-exam-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep corrections warm, practical, and short so the learner stays in motion."},{"id":"n5-review-and-final-exam-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"n5-review-and-final-exam-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Run a compact but real N5 review and final speaking loop that touches the major beginner systems.","supportNote":"Move from mimicry into real communication quickly."},{"id":"n5-review-and-final-exam-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Mark the learner complete only after they clear the final integrated N5 journey.","supportNote":"Use a short spoken check before advancing progress."},{"id":"n5-review-and-final-exam-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_levels (id, language_slug, official_label, product_label, objective, exam_title, pass_requirement, certificate_title, certificate_summary, sort_order)
values
  ('jp-n4', 'japanese', 'N4', 'Basic 2', 'Expand everyday communication with longer phrases and more flexible listening.', 'N4 speaking gate', 'Pass the level speaking checkpoint and final guided conversation.', 'N4 completion certificate', 'Issued after the learner passes the level exam and completes all modules.', 1)
on conflict (id) do update set
  official_label = excluded.official_label,
  product_label = excluded.product_label,
  objective = excluded.objective,
  exam_title = excluded.exam_title,
  pass_requirement = excluded.pass_requirement,
  certificate_title = excluded.certificate_title,
  certificate_summary = excluded.certificate_summary,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('jp-n4-roadmap', 'japanese', 'jp-n4', 'Progressive speaking roadmap', 'Unlock the next speaking curriculum with live listening, roleplay, and structured response practice.', 'Roadmap preview', 'Support language stays available for short beginner explanations.', 'not_started', 'Roadmap Ready', 10, $json$["Level preview","Future speaking goals","Roleplay expectations"]$json$::jsonb, 'Preview the next level before unlocking it', 'Peek at the next Japan mission so you know what stronger speaking will unlock.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('jp-n4-roadmap', 'japanese', 'jp-n4', 'jp-n4-roadmap', 'Progressive speaking roadmap', 18, 'speaking', 'Ready to speak this level with the tutor?', 'Say one short readiness response aloud.', 'Live guided conversation preview', 'Learner understands what speaking goals unlock in this level.', $json$["yes","ready","i am ready"]$json$::jsonb, $json$[{"id":"jp-n4-roadmap-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n4-roadmap-model","label":"AI models the phrase","type":"ai_model","prompt":"The AI previews what N4 speaking feels like in short phrases and live responses.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"jp-n4-roadmap-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"jp-n4-roadmap-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n4-roadmap-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"jp-n4-roadmap-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner one simple readiness question and one short spoken reply.","supportNote":"Move from mimicry into real communication quickly."},{"id":"jp-n4-roadmap-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Confirm the learner is ready for the next speaking path.","supportNote":"Use a short spoken check before advancing progress."},{"id":"jp-n4-roadmap-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_levels (id, language_slug, official_label, product_label, objective, exam_title, pass_requirement, certificate_title, certificate_summary, sort_order)
values
  ('jp-n3', 'japanese', 'N3', 'Intermediate 1', 'Handle practical real-world conversation with stronger comprehension.', 'N3 speaking gate', 'Pass the level speaking checkpoint and final guided conversation.', 'N3 completion certificate', 'Issued after the learner passes the level exam and completes all modules.', 2)
on conflict (id) do update set
  official_label = excluded.official_label,
  product_label = excluded.product_label,
  objective = excluded.objective,
  exam_title = excluded.exam_title,
  pass_requirement = excluded.pass_requirement,
  certificate_title = excluded.certificate_title,
  certificate_summary = excluded.certificate_summary,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('jp-n3-roadmap', 'japanese', 'jp-n3', 'Progressive speaking roadmap', 'Unlock the next speaking curriculum with live listening, roleplay, and structured response practice.', 'Roadmap preview', 'Support language stays available for short beginner explanations.', 'not_started', 'Roadmap Ready', 10, $json$["Level preview","Future speaking goals","Roleplay expectations"]$json$::jsonb, 'Preview the next level before unlocking it', 'Peek at the next Japan mission so you know what stronger speaking will unlock.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('jp-n3-roadmap', 'japanese', 'jp-n3', 'jp-n3-roadmap', 'Progressive speaking roadmap', 18, 'speaking', 'Ready to speak this level with the tutor?', 'Say one short readiness response aloud.', 'Live guided conversation preview', 'Learner understands what speaking goals unlock in this level.', $json$["yes","ready","i am ready"]$json$::jsonb, $json$[{"id":"jp-n3-roadmap-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n3-roadmap-model","label":"AI models the phrase","type":"ai_model","prompt":"The AI previews what N3 speaking feels like in short phrases and live responses.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"jp-n3-roadmap-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"jp-n3-roadmap-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n3-roadmap-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"jp-n3-roadmap-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner one simple readiness question and one short spoken reply.","supportNote":"Move from mimicry into real communication quickly."},{"id":"jp-n3-roadmap-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Confirm the learner is ready for the next speaking path.","supportNote":"Use a short spoken check before advancing progress."},{"id":"jp-n3-roadmap-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_levels (id, language_slug, official_label, product_label, objective, exam_title, pass_requirement, certificate_title, certificate_summary, sort_order)
values
  ('jp-n2', 'japanese', 'N2', 'Advanced 1', 'Build advanced fluency for study, work, and nuanced response control.', 'N2 speaking gate', 'Pass the level speaking checkpoint and final guided conversation.', 'N2 completion certificate', 'Issued after the learner passes the level exam and completes all modules.', 3)
on conflict (id) do update set
  official_label = excluded.official_label,
  product_label = excluded.product_label,
  objective = excluded.objective,
  exam_title = excluded.exam_title,
  pass_requirement = excluded.pass_requirement,
  certificate_title = excluded.certificate_title,
  certificate_summary = excluded.certificate_summary,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('jp-n2-roadmap', 'japanese', 'jp-n2', 'Progressive speaking roadmap', 'Unlock the next speaking curriculum with live listening, roleplay, and structured response practice.', 'Roadmap preview', 'Support language stays available for short beginner explanations.', 'not_started', 'Roadmap Ready', 10, $json$["Level preview","Future speaking goals","Roleplay expectations"]$json$::jsonb, 'Preview the next level before unlocking it', 'Peek at the next Japan mission so you know what stronger speaking will unlock.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('jp-n2-roadmap', 'japanese', 'jp-n2', 'jp-n2-roadmap', 'Progressive speaking roadmap', 18, 'speaking', 'Ready to speak this level with the tutor?', 'Say one short readiness response aloud.', 'Live guided conversation preview', 'Learner understands what speaking goals unlock in this level.', $json$["yes","ready","i am ready"]$json$::jsonb, $json$[{"id":"jp-n2-roadmap-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n2-roadmap-model","label":"AI models the phrase","type":"ai_model","prompt":"The AI previews what N2 speaking feels like in short phrases and live responses.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"jp-n2-roadmap-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"jp-n2-roadmap-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n2-roadmap-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"jp-n2-roadmap-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner one simple readiness question and one short spoken reply.","supportNote":"Move from mimicry into real communication quickly."},{"id":"jp-n2-roadmap-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Confirm the learner is ready for the next speaking path.","supportNote":"Use a short spoken check before advancing progress."},{"id":"jp-n2-roadmap-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_levels (id, language_slug, official_label, product_label, objective, exam_title, pass_requirement, certificate_title, certificate_summary, sort_order)
values
  ('jp-n1', 'japanese', 'N1', 'Advanced 2', 'Reach elite-level comprehension and polished spontaneous speaking.', 'N1 speaking gate', 'Pass the level speaking checkpoint and final guided conversation.', 'N1 completion certificate', 'Issued after the learner passes the level exam and completes all modules.', 4)
on conflict (id) do update set
  official_label = excluded.official_label,
  product_label = excluded.product_label,
  objective = excluded.objective,
  exam_title = excluded.exam_title,
  pass_requirement = excluded.pass_requirement,
  certificate_title = excluded.certificate_title,
  certificate_summary = excluded.certificate_summary,
  sort_order = excluded.sort_order;

insert into public.curriculum_modules (id, language_slug, level_id, title, objective, checkpoint_label, support_language_hint, completion_state, reward_badge, reward_xp, coverage, mission_title, story_hook, progress_defaults, resource_links, sort_order)
values
  ('jp-n1-roadmap', 'japanese', 'jp-n1', 'Progressive speaking roadmap', 'Unlock the next speaking curriculum with live listening, roleplay, and structured response practice.', 'Roadmap preview', 'Support language stays available for short beginner explanations.', 'not_started', 'Roadmap Ready', 10, $json$["Level preview","Future speaking goals","Roleplay expectations"]$json$::jsonb, 'Preview the next level before unlocking it', 'Peek at the next Japan mission so you know what stronger speaking will unlock.', $json${"state":"not_started","completedLessons":0,"totalLessons":1}$json$::jsonb, $json${}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  objective = excluded.objective,
  checkpoint_label = excluded.checkpoint_label,
  support_language_hint = excluded.support_language_hint,
  completion_state = excluded.completion_state,
  reward_badge = excluded.reward_badge,
  reward_xp = excluded.reward_xp,
  coverage = excluded.coverage,
  mission_title = excluded.mission_title,
  story_hook = excluded.story_hook,
  progress_defaults = excluded.progress_defaults,
  resource_links = excluded.resource_links,
  sort_order = excluded.sort_order;

insert into public.curriculum_lessons (id, language_slug, level_id, module_id, title, duration_minutes, mode, demo_phrase, reply_prompt, target_pattern, learner_outcome, acceptable_responses, turns, feedback, sort_order)
values
  ('jp-n1-roadmap', 'japanese', 'jp-n1', 'jp-n1-roadmap', 'Progressive speaking roadmap', 18, 'speaking', 'Ready to speak this level with the tutor?', 'Say one short readiness response aloud.', 'Live guided conversation preview', 'Learner understands what speaking goals unlock in this level.', $json$["yes","ready","i am ready"]$json$::jsonb, $json$[{"id":"jp-n1-roadmap-warm-up","label":"Warm-up","type":"warm_up","prompt":"Start with a short confidence reset and remind the learner what they are about to say.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n1-roadmap-model","label":"AI models the phrase","type":"ai_model","prompt":"The AI previews what N1 speaking feels like in short phrases and live responses.","supportNote":"The AI says it naturally first, then once more slowly."},{"id":"jp-n1-roadmap-repeat","label":"Learner repeats","type":"learner_repeat","prompt":"Learner answers by voice. The goal is speaking frequently, not reading long explanations.","supportNote":"Capture pronunciation, timing, and confidence on the first attempt."},{"id":"jp-n1-roadmap-feedback","label":"Instant feedback","type":"feedback","prompt":"Give one short correction in the learner's support language, then return to speaking.","supportNote":"Keep the explanation simple, brief, and confidence-building."},{"id":"jp-n1-roadmap-retry","label":"Retry","type":"retry","prompt":"Ask for one cleaner retry only when needed so the lesson keeps momentum.","supportNote":"Prioritize clarity and confidence over perfection."},{"id":"jp-n1-roadmap-guided","label":"Guided prompt-response","type":"guided_prompt","prompt":"Ask the learner one simple readiness question and one short spoken reply.","supportNote":"Move from mimicry into real communication quickly."},{"id":"jp-n1-roadmap-checkpoint","label":"Module checkpoint","type":"checkpoint","prompt":"Confirm the learner is ready for the next speaking path.","supportNote":"Use a short spoken check before advancing progress."},{"id":"jp-n1-roadmap-summary","label":"Lesson summary","type":"summary","prompt":"End with a short spoken recap, what improved, and what to remember next.","supportNote":"Keep the closeout concise so the lesson still feels live."}]$json$::jsonb, $json${"focus":"Pronunciation, clarity, and response confidence","successSignal":"Learner can answer once naturally without relying on a written script.","correctionStyle":"One practical correction at a time in plain support-language wording.","retryCue":"Repeat once more with calmer pacing and a cleaner final syllable."}$json$::jsonb, 0)
on conflict (id) do update set
  title = excluded.title,
  duration_minutes = excluded.duration_minutes,
  mode = excluded.mode,
  demo_phrase = excluded.demo_phrase,
  reply_prompt = excluded.reply_prompt,
  target_pattern = excluded.target_pattern,
  learner_outcome = excluded.learner_outcome,
  acceptable_responses = excluded.acceptable_responses,
  turns = excluded.turns,
  feedback = excluded.feedback,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('greetings', 'japanese', 'Greetings', 0)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-1', 'greetings', 'japanese', 'おはようございます', 'ohayou gozaimasu', 'good morning', 'おはようございます、ゆきさん。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-2', 'greetings', 'japanese', 'こんにちは', 'konnichiwa', 'hello', 'こんにちは、はじめまして。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-3', 'greetings', 'japanese', 'こんばんは', 'konbanwa', 'good evening', 'こんばんは、さくらさん。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-4', 'greetings', 'japanese', 'おやすみなさい', 'oyasuminasai', 'good night', 'おやすみなさい。またあした。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-5', 'greetings', 'japanese', 'さようなら', 'sayounara', 'goodbye', 'さようなら。きをつけて。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-6', 'greetings', 'japanese', 'またね', 'mata ne', 'see you', 'またね。あしたあおう。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-7', 'greetings', 'japanese', 'はじめまして', 'hajimemashite', 'nice to meet you', 'はじめましてをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-8', 'greetings', 'japanese', 'おげんきですか', 'ogenki desu ka', 'how are you', 'おげんきですかをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-9', 'greetings', 'japanese', 'げんきです', 'genki desu', 'I am fine', 'げんきですをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-10', 'greetings', 'japanese', 'いってきます', 'ittekimasu', 'I am leaving and will come back', 'いってきますをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-11', 'greetings', 'japanese', 'いってらっしゃい', 'itterasshai', 'take care, see you later', 'いってらっしゃいをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-12', 'greetings', 'japanese', 'ただいま', 'tadaima', 'I am home', 'ただいまをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-13', 'greetings', 'japanese', 'おかえりなさい', 'okaerinasai', 'welcome back', 'おかえりなさいをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-14', 'greetings', 'japanese', 'しつれいします', 'shitsurei shimasu', 'excuse me', 'しつれいしますをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-15', 'greetings', 'japanese', 'おめでとうございます', 'omedetou gozaimasu', 'congratulations', 'おめでとうございますをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-16', 'greetings', 'japanese', 'あけましておめでとうございます', 'akemashite omedetou gozaimasu', 'happy new year', 'あけましておめでとうございますをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-17', 'greetings', 'japanese', 'おひさしぶりです', 'ohisashiburi desu', 'long time no see', 'おひさしぶりですをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-18', 'greetings', 'japanese', 'またあした', 'mata ashita', 'see you tomorrow', 'またあしたをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-19', 'greetings', 'japanese', 'またこんど', 'mata kondo', 'see you next time', 'またこんどをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-20', 'greetings', 'japanese', 'きをつけて', 'ki o tsukete', 'take care', 'きをつけてをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-21', 'greetings', 'japanese', 'いただきます', 'itadakimasu', 'let''s eat', 'いただきますをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-22', 'greetings', 'japanese', 'ごちそうさまでした', 'gochisousama deshita', 'thank you for the meal', 'ごちそうさまでしたをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-23', 'greetings', 'japanese', 'もしもし', 'moshi moshi', 'hello on the phone', 'もしもしをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-24', 'greetings', 'japanese', 'ようこそ', 'youkoso', 'welcome', 'ようこそをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-25', 'greetings', 'japanese', 'おさきにしつれいします', 'osaki ni shitsurei shimasu', 'excuse me for leaving first', 'おさきにしつれいしますをつかったれんしゅうをします。', 24)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('greetings-26', 'greetings', 'japanese', 'おつかれさまです', 'otsukaresama desu', 'thank you for your work', 'おつかれさまですをつかったれんしゅうをします。', 25)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('classroom-japanese', 'japanese', 'Classroom Japanese', 1)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-1', 'classroom-japanese', 'japanese', 'きいてください', 'kiite kudasai', 'please listen', 'せんせいのこえをきいてください。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-2', 'classroom-japanese', 'japanese', 'いってください', 'itte kudasai', 'please say it', 'もういちどいってください。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-3', 'classroom-japanese', 'japanese', 'みてください', 'mite kudasai', 'please look', 'ここのれいをみてください。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-4', 'classroom-japanese', 'japanese', 'かいてください', 'kaite kudasai', 'please write', 'ノートにかいてください。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-5', 'classroom-japanese', 'japanese', 'よんでください', 'yonde kudasai', 'please read', 'このぶんをよんでください。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-6', 'classroom-japanese', 'japanese', 'わかりました', 'wakarimashita', 'I understood', 'はい、わかりました。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-7', 'classroom-japanese', 'japanese', 'しつもんがあります', 'shitsumon ga arimasu', 'I have a question', 'しつもんがありますをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-8', 'classroom-japanese', 'japanese', 'もういちど', 'mou ichido', 'one more time', 'もういちどをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-9', 'classroom-japanese', 'japanese', 'ゆっくり', 'yukkuri', 'slowly', 'ゆっくりをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-10', 'classroom-japanese', 'japanese', 'だいじょうぶです', 'daijoubu desu', 'it is okay', 'だいじょうぶですをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-11', 'classroom-japanese', 'japanese', 'ノート', 'nooto', 'notebook', 'ノートをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-12', 'classroom-japanese', 'japanese', 'れい', 'rei', 'example', 'れいをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-13', 'classroom-japanese', 'japanese', 'こたえ', 'kotae', 'answer', 'こたえをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-14', 'classroom-japanese', 'japanese', 'もんだい', 'mondai', 'problem or question', 'もんだいをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-15', 'classroom-japanese', 'japanese', 'テスト', 'tesuto', 'test', 'テストをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-16', 'classroom-japanese', 'japanese', 'れんしゅう', 'renshuu', 'practice', 'れんしゅうをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-17', 'classroom-japanese', 'japanese', 'べんきょう', 'benkyou', 'study', 'べんきょうをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-18', 'classroom-japanese', 'japanese', 'しゅくだい', 'shukudai', 'homework', 'しゅくだいをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-19', 'classroom-japanese', 'japanese', 'きょうかしょ', 'kyoukasho', 'textbook', 'きょうかしょをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-20', 'classroom-japanese', 'japanese', 'じしょ', 'jisho', 'dictionary', 'じしょをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-21', 'classroom-japanese', 'japanese', 'おしえてください', 'oshiete kudasai', 'please teach me', 'おしえてくださいをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-22', 'classroom-japanese', 'japanese', 'つぎ', 'tsugi', 'next', 'つぎをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-23', 'classroom-japanese', 'japanese', 'さいしょ', 'saisho', 'first', 'さいしょをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-24', 'classroom-japanese', 'japanese', 'さいご', 'saigo', 'last', 'さいごをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-25', 'classroom-japanese', 'japanese', 'ただしい', 'tadashii', 'correct', 'ただしいをつかったれんしゅうをします。', 24)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('classroom-japanese-26', 'classroom-japanese', 'japanese', 'まちがい', 'machigai', 'mistake', 'まちがいをつかったれんしゅうをします。', 25)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('time-expressions', 'japanese', 'Time Expressions', 2)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-1', 'time-expressions', 'japanese', 'いま', 'ima', 'now', 'いまべんきょうしています。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-2', 'time-expressions', 'japanese', 'きょう', 'kyou', 'today', 'きょうはあめです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-3', 'time-expressions', 'japanese', 'あした', 'ashita', 'tomorrow', 'あしたにほんごをべんきょうします。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-4', 'time-expressions', 'japanese', 'きのう', 'kinou', 'yesterday', 'きのうほんをよみました。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-5', 'time-expressions', 'japanese', 'まいにち', 'mainichi', 'every day', 'まいにちれんしゅうします。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-6', 'time-expressions', 'japanese', 'あとで', 'ato de', 'later', 'あとでコーヒーをのみます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-7', 'time-expressions', 'japanese', 'けさ', 'kesa', 'this morning', 'けさをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-8', 'time-expressions', 'japanese', 'こんや', 'konya', 'tonight', 'こんやをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-9', 'time-expressions', 'japanese', 'こんばん', 'konban', 'this evening', 'こんばんをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-10', 'time-expressions', 'japanese', 'こんしゅう', 'konshuu', 'this week', 'こんしゅうをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-11', 'time-expressions', 'japanese', 'らいしゅう', 'raishuu', 'next week', 'らいしゅうをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-12', 'time-expressions', 'japanese', 'せんしゅう', 'senshuu', 'last week', 'せんしゅうをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-13', 'time-expressions', 'japanese', 'こんげつ', 'kongetsu', 'this month', 'こんげつをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-14', 'time-expressions', 'japanese', 'らいげつ', 'raigetsu', 'next month', 'らいげつをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-15', 'time-expressions', 'japanese', 'せんげつ', 'sengetsu', 'last month', 'せんげつをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-16', 'time-expressions', 'japanese', 'ことし', 'kotoshi', 'this year', 'ことしをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-17', 'time-expressions', 'japanese', 'らいねん', 'rainen', 'next year', 'らいねんをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-18', 'time-expressions', 'japanese', 'きょねん', 'kyonen', 'last year', 'きょねんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-19', 'time-expressions', 'japanese', 'まいあさ', 'maiasa', 'every morning', 'まいあさをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-20', 'time-expressions', 'japanese', 'まいばん', 'maiban', 'every night', 'まいばんをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-21', 'time-expressions', 'japanese', 'いつも', 'itsumo', 'always', 'いつもをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-22', 'time-expressions', 'japanese', 'ときどき', 'tokidoki', 'sometimes', 'ときどきをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-23', 'time-expressions', 'japanese', 'すぐ', 'sugu', 'right away', 'すぐをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-24', 'time-expressions', 'japanese', 'さっき', 'sakki', 'a little while ago', 'さっきをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-25', 'time-expressions', 'japanese', 'このあと', 'kono ato', 'after this', 'このあとをつかったれんしゅうをします。', 24)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('time-expressions-26', 'time-expressions', 'japanese', 'そのあと', 'sono ato', 'after that', 'そのあとをつかったれんしゅうをします。', 25)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('weekdays', 'japanese', 'Days of the Week', 3)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-1', 'weekdays', 'japanese', 'げつようび', 'getsuyoubi', 'Monday', 'げつようびにがっこうへいきます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-2', 'weekdays', 'japanese', 'かようび', 'kayoubi', 'Tuesday', 'かようびはしごとです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-3', 'weekdays', 'japanese', 'すいようび', 'suiyoubi', 'Wednesday', 'すいようびにともだちにあいます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-4', 'weekdays', 'japanese', 'もくようび', 'mokuyoubi', 'Thursday', 'もくようびによるべんきょうします。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-5', 'weekdays', 'japanese', 'きんようび', 'kinyoubi', 'Friday', 'きんようびはレストランへいきます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-6', 'weekdays', 'japanese', 'にちようび', 'nichiyoubi', 'Sunday', 'にちようびにやすみます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-7', 'weekdays', 'japanese', 'しゅうまつ', 'shuumatsu', 'weekend', 'しゅうまつをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-8', 'weekdays', 'japanese', 'へいじつ', 'heijitsu', 'weekday', 'へいじつをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-9', 'weekdays', 'japanese', 'げつ', 'getsu', 'Monday short form', 'げつをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-10', 'weekdays', 'japanese', 'か', 'ka', 'Tuesday short form', 'かをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-11', 'weekdays', 'japanese', 'すい', 'sui', 'Wednesday short form', 'すいをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-12', 'weekdays', 'japanese', 'もく', 'moku', 'Thursday short form', 'もくをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-13', 'weekdays', 'japanese', 'きん', 'kin', 'Friday short form', 'きんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-14', 'weekdays', 'japanese', 'ど', 'do', 'Saturday short form', 'どをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-15', 'weekdays', 'japanese', 'にち', 'nichi', 'Sunday short form', 'にちをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-16', 'weekdays', 'japanese', 'まいしゅう', 'maishuu', 'every week', 'まいしゅうをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-17', 'weekdays', 'japanese', 'こんどのげつようび', 'kondo no getsuyoubi', 'this coming Monday', 'こんどのげつようびをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-18', 'weekdays', 'japanese', 'らいしゅうのかようび', 'raishuu no kayoubi', 'next Tuesday', 'らいしゅうのかようびをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-19', 'weekdays', 'japanese', 'にちようのあさ', 'nichiyou no asa', 'Sunday morning', 'にちようのあさをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-20', 'weekdays', 'japanese', 'きんようのよる', 'kinyou no yoru', 'Friday night', 'きんようのよるをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-21', 'weekdays', 'japanese', 'どようびのごご', 'doyoubi no gogo', 'Saturday afternoon', 'どようびのごごをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-22', 'weekdays', 'japanese', 'やすみのひ', 'yasumi no hi', 'day off', 'やすみのひをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-23', 'weekdays', 'japanese', 'しごとのひ', 'shigoto no hi', 'work day', 'しごとのひをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weekdays-24', 'weekdays', 'japanese', 'がっこうのひ', 'gakkou no hi', 'school day', 'がっこうのひをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('months-dates', 'japanese', 'Months and Dates', 4)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-1', 'months-dates', 'japanese', 'いちがつ', 'ichigatsu', 'January', 'いちがつはさむいです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-2', 'months-dates', 'japanese', 'しがつ', 'shigatsu', 'April', 'しがつにがっこうがはじまります。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-3', 'months-dates', 'japanese', 'しちがつ', 'shichigatsu', 'July', 'しちがつはあついです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-4', 'months-dates', 'japanese', 'じゅうにがつ', 'juunigatsu', 'December', 'じゅうにがつにかえります。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-5', 'months-dates', 'japanese', 'ついたち', 'tsuitachi', 'first day of month', 'ついたちにかいものします。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-6', 'months-dates', 'japanese', 'じゅうよっか', 'juuyokka', 'fourteenth day', 'じゅうよっかにともだちとあいます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-7', 'months-dates', 'japanese', 'にがつ', 'nigatsu', 'February', 'にがつをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-8', 'months-dates', 'japanese', 'さんがつ', 'sangatsu', 'March', 'さんがつをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-9', 'months-dates', 'japanese', 'ごがつ', 'gogatsu', 'May', 'ごがつをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-10', 'months-dates', 'japanese', 'ろくがつ', 'rokugatsu', 'June', 'ろくがつをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-11', 'months-dates', 'japanese', 'はちがつ', 'hachigatsu', 'August', 'はちがつをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-12', 'months-dates', 'japanese', 'くがつ', 'kugatsu', 'September', 'くがつをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-13', 'months-dates', 'japanese', 'じゅうがつ', 'juugatsu', 'October', 'じゅうがつをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-14', 'months-dates', 'japanese', 'じゅういちがつ', 'juuichigatsu', 'November', 'じゅういちがつをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-15', 'months-dates', 'japanese', 'ふつか', 'futsuka', 'second day', 'ふつかをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-16', 'months-dates', 'japanese', 'みっか', 'mikka', 'third day', 'みっかをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-17', 'months-dates', 'japanese', 'よっか', 'yokka', 'fourth day', 'よっかをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-18', 'months-dates', 'japanese', 'いつか', 'itsuka', 'fifth day', 'いつかをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-19', 'months-dates', 'japanese', 'むいか', 'muika', 'sixth day', 'むいかをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-20', 'months-dates', 'japanese', 'なのか', 'nanoka', 'seventh day', 'なのかをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-21', 'months-dates', 'japanese', 'ようか', 'youka', 'eighth day', 'ようかをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-22', 'months-dates', 'japanese', 'ここのか', 'kokonoka', 'ninth day', 'ここのかをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-23', 'months-dates', 'japanese', 'とおか', 'tooka', 'tenth day', 'とおかをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-24', 'months-dates', 'japanese', 'はつか', 'hatsuka', 'twentieth day', 'はつかをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-25', 'months-dates', 'japanese', 'にじゅうよっか', 'nijuuyokka', 'twenty fourth day', 'にじゅうよっかをつかったれんしゅうをします。', 24)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('months-dates-26', 'months-dates', 'japanese', 'さんじゅうにち', 'sanjuunichi', 'thirtieth day', 'さんじゅうにちをつかったれんしゅうをします。', 25)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('numbers', 'japanese', 'Numbers', 5)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-1', 'numbers', 'japanese', 'いち', 'ichi', 'one', 'いちからごまでいってください。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-2', 'numbers', 'japanese', 'さん', 'san', 'three', 'さんこください。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-3', 'numbers', 'japanese', 'よん', 'yon', 'four', 'よんじです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-4', 'numbers', 'japanese', 'なな', 'nana', 'seven', 'ななにんいます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-5', 'numbers', 'japanese', 'じゅう', 'juu', 'ten', 'じゅうえんです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-6', 'numbers', 'japanese', 'ひゃく', 'hyaku', 'one hundred', 'ひゃくえんです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-7', 'numbers', 'japanese', 'れい', 'rei', 'zero', 'れいをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-8', 'numbers', 'japanese', 'にひゃく', 'nihyaku', 'two hundred', 'にひゃくをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-9', 'numbers', 'japanese', 'さんびゃく', 'sanbyaku', 'three hundred', 'さんびゃくをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-10', 'numbers', 'japanese', 'ろっぴゃく', 'roppyaku', 'six hundred', 'ろっぴゃくをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-11', 'numbers', 'japanese', 'はっぴゃく', 'happyaku', 'eight hundred', 'はっぴゃくをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-12', 'numbers', 'japanese', 'せん', 'sen', 'one thousand', 'せんをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-13', 'numbers', 'japanese', 'にせん', 'nisen', 'two thousand', 'にせんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-14', 'numbers', 'japanese', 'さんぜん', 'sanzen', 'three thousand', 'さんぜんをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-15', 'numbers', 'japanese', 'よんせん', 'yonsen', 'four thousand', 'よんせんをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-16', 'numbers', 'japanese', 'ごせん', 'gosen', 'five thousand', 'ごせんをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-17', 'numbers', 'japanese', 'ろくせん', 'rokusen', 'six thousand', 'ろくせんをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-18', 'numbers', 'japanese', 'ななせん', 'nanasen', 'seven thousand', 'ななせんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-19', 'numbers', 'japanese', 'はっせん', 'hassen', 'eight thousand', 'はっせんをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-20', 'numbers', 'japanese', 'きゅうせん', 'kyuusen', 'nine thousand', 'きゅうせんをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-21', 'numbers', 'japanese', 'いちまん', 'ichiman', 'ten thousand', 'いちまんをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-22', 'numbers', 'japanese', 'なんばん', 'nanban', 'what number', 'なんばんをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-23', 'numbers', 'japanese', 'なんこ', 'nanko', 'how many things', 'なんこをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('numbers-24', 'numbers', 'japanese', 'たくさん', 'takusan', 'many', 'たくさんをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('money', 'japanese', 'Money', 6)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-1', 'money', 'japanese', 'えん', 'en', 'yen', 'ごひゃくえんです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-2', 'money', 'japanese', 'いくら', 'ikura', 'how much', 'これはいくらですか。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-3', 'money', 'japanese', 'たかい', 'takai', 'expensive', 'このバッグはたかいです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-4', 'money', 'japanese', 'やすい', 'yasui', 'cheap', 'このパンはやすいです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-5', 'money', 'japanese', 'せんえん', 'sen en', 'one thousand yen', 'せんえんあります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-6', 'money', 'japanese', 'おつり', 'otsuri', 'change', 'おつりをください。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-7', 'money', 'japanese', 'おかね', 'okane', 'money', 'おかねをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-8', 'money', 'japanese', 'かいけい', 'kaikei', 'bill or check', 'かいけいをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-9', 'money', 'japanese', 'はらいます', 'haraimasu', 'to pay', 'はらいますをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-10', 'money', 'japanese', 'げんきん', 'genkin', 'cash', 'げんきんをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-11', 'money', 'japanese', 'カード', 'kaado', 'card', 'カードをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-12', 'money', 'japanese', 'りょうしゅうしょ', 'ryoushuusho', 'receipt', 'りょうしゅうしょをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-13', 'money', 'japanese', 'ねだん', 'nedan', 'price', 'ねだんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-14', 'money', 'japanese', 'やすく', 'yasuku', 'cheaply', 'やすくをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-15', 'money', 'japanese', 'たかく', 'takaku', 'expensively', 'たかくをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-16', 'money', 'japanese', 'セール', 'seeru', 'sale', 'セールをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-17', 'money', 'japanese', 'はんがく', 'hangaku', 'half price', 'はんがくをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-18', 'money', 'japanese', 'むりょう', 'muryou', 'free of charge', 'むりょうをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-19', 'money', 'japanese', 'しょうひぜい', 'shouhizei', 'consumption tax', 'しょうひぜいをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-20', 'money', 'japanese', 'おさつ', 'osatsu', 'bank note', 'おさつをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-21', 'money', 'japanese', 'こぜに', 'kozeni', 'small coins', 'こぜにをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-22', 'money', 'japanese', 'いちまんえん', 'ichiman en', 'ten thousand yen', 'いちまんえんをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-23', 'money', 'japanese', 'さんびゃくえん', 'sanbyaku en', 'three hundred yen', 'さんびゃくえんをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('money-24', 'money', 'japanese', 'ごせんえん', 'gosen en', 'five thousand yen', 'ごせんえんをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('family', 'japanese', 'Family Terms', 7)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-1', 'family', 'japanese', 'かぞく', 'kazoku', 'family', 'わたしのかぞくはよにんです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-2', 'family', 'japanese', 'ちち', 'chichi', 'my father', 'ちちはせんせいです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-3', 'family', 'japanese', 'はは', 'haha', 'my mother', 'はははりょうりがじょうずです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-4', 'family', 'japanese', 'あに', 'ani', 'older brother', 'あにはとうきょうにいます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-5', 'family', 'japanese', 'あね', 'ane', 'older sister', 'あねはがくせいです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-6', 'family', 'japanese', 'いもうと', 'imouto', 'younger sister', 'いもうとはげんきです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-7', 'family', 'japanese', 'りょうしん', 'ryoushin', 'parents', 'りょうしんをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-8', 'family', 'japanese', 'ふうふ', 'fuufu', 'married couple', 'ふうふをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-9', 'family', 'japanese', 'つま', 'tsuma', 'my wife', 'つまをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-10', 'family', 'japanese', 'おくさん', 'okusan', 'someone''s wife', 'おくさんをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-11', 'family', 'japanese', 'おっと', 'otto', 'my husband', 'おっとをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-12', 'family', 'japanese', 'ごしゅじん', 'goshujin', 'someone''s husband', 'ごしゅじんをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-13', 'family', 'japanese', 'むすこ', 'musuko', 'son', 'むすこをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-14', 'family', 'japanese', 'むすめ', 'musume', 'daughter', 'むすめをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-15', 'family', 'japanese', 'おじいさん', 'ojiisan', 'grandfather', 'おじいさんをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-16', 'family', 'japanese', 'おばあさん', 'obaasan', 'grandmother', 'おばあさんをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-17', 'family', 'japanese', 'まご', 'mago', 'grandchild', 'まごをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-18', 'family', 'japanese', 'おじ', 'oji', 'uncle', 'おじをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-19', 'family', 'japanese', 'おば', 'oba', 'aunt', 'おばをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-20', 'family', 'japanese', 'いとこ', 'itoko', 'cousin', 'いとこをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-21', 'family', 'japanese', 'きょうだい', 'kyoudai', 'siblings', 'きょうだいをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-22', 'family', 'japanese', 'ひとりっこ', 'hitorikko', 'only child', 'ひとりっこをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-23', 'family', 'japanese', 'かぞくしゃしん', 'kazoku shashin', 'family photo', 'かぞくしゃしんをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('family-24', 'family', 'japanese', 'いえのひと', 'ie no hito', 'family member', 'いえのひとをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('people', 'japanese', 'People', 8)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-1', 'people', 'japanese', 'わたし', 'watashi', 'I', 'わたしはラフルです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-2', 'people', 'japanese', 'あなた', 'anata', 'you', 'あなたはがくせいですか。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-3', 'people', 'japanese', 'ひと', 'hito', 'person', 'あのひとはせんせいです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-4', 'people', 'japanese', 'ともだち', 'tomodachi', 'friend', 'ともだちとえきへいきます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-5', 'people', 'japanese', 'がくせい', 'gakusei', 'student', 'わたしはがくせいです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-6', 'people', 'japanese', 'せんせい', 'sensei', 'teacher', 'せんせいはやさしいです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-7', 'people', 'japanese', 'みんな', 'minna', 'everyone', 'みんなをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-8', 'people', 'japanese', 'だれか', 'dareka', 'someone', 'だれかをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-9', 'people', 'japanese', 'じぶん', 'jibun', 'oneself', 'じぶんをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-10', 'people', 'japanese', 'こいびと', 'koibito', 'boyfriend or girlfriend', 'こいびとをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-11', 'people', 'japanese', 'おとな', 'otona', 'adult', 'おとなをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-12', 'people', 'japanese', 'わかもの', 'wakamono', 'young person', 'わかものをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-13', 'people', 'japanese', 'あかちゃん', 'akachan', 'baby', 'あかちゃんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-14', 'people', 'japanese', 'おきゃくさん', 'okyakusan', 'customer or guest', 'おきゃくさんをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-15', 'people', 'japanese', 'てんいん', 'tenin', 'store clerk', 'てんいんをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-16', 'people', 'japanese', 'せいと', 'seito', 'pupil', 'せいとをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-17', 'people', 'japanese', 'どうりょう', 'douryou', 'coworker', 'どうりょうをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-18', 'people', 'japanese', 'しゃいん', 'shain', 'employee', 'しゃいんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-19', 'people', 'japanese', 'しんせつなひと', 'shinsetsu na hito', 'kind person', 'しんせつなひとをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-20', 'people', 'japanese', 'ゆうめいじん', 'yuumeijin', 'famous person', 'ゆうめいじんをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-21', 'people', 'japanese', 'にほんじん', 'nihonjin', 'Japanese person', 'にほんじんをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-22', 'people', 'japanese', 'がいこくじん', 'gaikokujin', 'foreigner', 'がいこくじんをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-23', 'people', 'japanese', 'せんぱい', 'senpai', 'senior', 'せんぱいをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('people-24', 'people', 'japanese', 'こうはい', 'kouhai', 'junior', 'こうはいをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('jobs', 'japanese', 'Jobs', 9)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-1', 'jobs', 'japanese', 'エンジニア', 'enjinia', 'engineer', 'わたしはエンジニアです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-2', 'jobs', 'japanese', 'いしゃ', 'isha', 'doctor', 'ちちはいしゃです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-3', 'jobs', 'japanese', 'かいしゃいん', 'kaishain', 'office worker', 'あにはかいしゃいんです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-4', 'jobs', 'japanese', 'てんいん', 'tenin', 'shop clerk', 'てんいんにききます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-5', 'jobs', 'japanese', 'りょうりにん', 'ryourinin', 'cook', 'りょうりにんはラーメンをつくります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-6', 'jobs', 'japanese', 'せいと', 'seito', 'pupil', 'せいとはきいています。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-7', 'jobs', 'japanese', 'エンジニア', 'enjinia', 'engineer', 'エンジニアをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-8', 'jobs', 'japanese', 'いしゃ', 'isha', 'doctor', 'いしゃをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-9', 'jobs', 'japanese', 'かんごし', 'kangoshi', 'nurse', 'かんごしをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-10', 'jobs', 'japanese', 'てんいん', 'tenin', 'shop clerk', 'てんいんをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-11', 'jobs', 'japanese', 'うんてんしゅ', 'untenshu', 'driver', 'うんてんしゅをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-12', 'jobs', 'japanese', 'けいさつかん', 'keisatsukan', 'police officer', 'けいさつかんをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-13', 'jobs', 'japanese', 'ぎんこういん', 'ginkouin', 'bank employee', 'ぎんこういんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-14', 'jobs', 'japanese', 'かいしゃいん', 'kaishain', 'company employee', 'かいしゃいんをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-15', 'jobs', 'japanese', 'シェフ', 'shefu', 'chef', 'シェフをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-16', 'jobs', 'japanese', 'ウェイター', 'weitaa', 'waiter', 'ウェイターをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-17', 'jobs', 'japanese', 'アルバイト', 'arubaito', 'part-time worker', 'アルバイトをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-18', 'jobs', 'japanese', 'がくしゃ', 'gakusha', 'scholar', 'がくしゃをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-19', 'jobs', 'japanese', 'だいがくせい', 'daigakusei', 'university student', 'だいがくせいをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-20', 'jobs', 'japanese', 'こうこうせい', 'koukousei', 'high school student', 'こうこうせいをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-21', 'jobs', 'japanese', 'しょうがくせい', 'shougakusei', 'elementary school student', 'しょうがくせいをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-22', 'jobs', 'japanese', 'かしゅ', 'kashu', 'singer', 'かしゅをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-23', 'jobs', 'japanese', 'えんぎしゃ', 'engisha', 'actor', 'えんぎしゃをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('jobs-24', 'jobs', 'japanese', 'りょうりにん', 'ryourinin', 'cook', 'りょうりにんをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('countries', 'japanese', 'Countries', 10)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-1', 'countries', 'japanese', 'にほん', 'nihon', 'Japan', 'にほんへいきたいです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-2', 'countries', 'japanese', 'インド', 'indo', 'India', 'インドからきました。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-3', 'countries', 'japanese', 'アメリカ', 'amerika', 'America', 'アメリカのともだちです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-4', 'countries', 'japanese', 'ちゅうごく', 'chuugoku', 'China', 'ちゅうごくごをべんきょうします。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-5', 'countries', 'japanese', 'かんこく', 'kankoku', 'Korea', 'かんこくへいったことがあります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-6', 'countries', 'japanese', 'イギリス', 'igirisu', 'United Kingdom', 'イギリスのホテルです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-7', 'countries', 'japanese', 'にほん', 'nihon', 'Japan', 'にほんをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-8', 'countries', 'japanese', 'ちゅうごく', 'chuugoku', 'China', 'ちゅうごくをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-9', 'countries', 'japanese', 'かんこく', 'kankoku', 'Korea', 'かんこくをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-10', 'countries', 'japanese', 'イギリス', 'igirisu', 'United Kingdom', 'イギリスをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-11', 'countries', 'japanese', 'フランス', 'furansu', 'France', 'フランスをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-12', 'countries', 'japanese', 'ドイツ', 'doitsu', 'Germany', 'ドイツをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-13', 'countries', 'japanese', 'スペイン', 'supein', 'Spain', 'スペインをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-14', 'countries', 'japanese', 'イタリア', 'itaria', 'Italy', 'イタリアをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-15', 'countries', 'japanese', 'オーストラリア', 'oosutoraria', 'Australia', 'オーストラリアをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-16', 'countries', 'japanese', 'カナダ', 'kanada', 'Canada', 'カナダをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-17', 'countries', 'japanese', 'ブラジル', 'burajiru', 'Brazil', 'ブラジルをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-18', 'countries', 'japanese', 'タイ', 'tai', 'Thailand', 'タイをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-19', 'countries', 'japanese', 'ベトナム', 'betonamu', 'Vietnam', 'ベトナムをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-20', 'countries', 'japanese', 'インドネシア', 'indoneshia', 'Indonesia', 'インドネシアをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-21', 'countries', 'japanese', 'フィリピン', 'firipin', 'Philippines', 'フィリピンをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-22', 'countries', 'japanese', 'ロシア', 'roshia', 'Russia', 'ロシアをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-23', 'countries', 'japanese', 'メキシコ', 'mekishiko', 'Mexico', 'メキシコをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('countries-24', 'countries', 'japanese', 'ネパール', 'nepaaru', 'Nepal', 'ネパールをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('languages', 'japanese', 'Languages', 11)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-1', 'languages', 'japanese', 'にほんご', 'nihongo', 'Japanese language', 'にほんごをべんきょうしています。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-2', 'languages', 'japanese', 'えいご', 'eigo', 'English', 'えいごはわかりますか。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-3', 'languages', 'japanese', 'ちゅうごくご', 'chuugokugo', 'Chinese language', 'ちゅうごくごはむずかしいです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-4', 'languages', 'japanese', 'かんこくご', 'kankokugo', 'Korean language', 'かんこくごもすきです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-5', 'languages', 'japanese', 'フランスご', 'furansugo', 'French language', 'フランスごをききます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-6', 'languages', 'japanese', 'スペインご', 'supeingo', 'Spanish language', 'スペインごのうたです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-7', 'languages', 'japanese', 'にほんご', 'nihongo', 'Japanese language', 'にほんごをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-8', 'languages', 'japanese', 'えいご', 'eigo', 'English language', 'えいごをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-9', 'languages', 'japanese', 'ちゅうごくご', 'chuugokugo', 'Chinese language', 'ちゅうごくごをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-10', 'languages', 'japanese', 'かんこくご', 'kankokugo', 'Korean language', 'かんこくごをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-11', 'languages', 'japanese', 'フランスご', 'furansugo', 'French language', 'フランスごをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-12', 'languages', 'japanese', 'ドイツご', 'doitsugo', 'German language', 'ドイツごをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-13', 'languages', 'japanese', 'スペインご', 'supeingo', 'Spanish language', 'スペインごをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-14', 'languages', 'japanese', 'ヒンディーご', 'hindii go', 'Hindi language', 'ヒンディーごをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-15', 'languages', 'japanese', 'ことば', 'kotoba', 'word or language', 'ことばをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-16', 'languages', 'japanese', 'はつおん', 'hatsuon', 'pronunciation', 'はつおんをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-17', 'languages', 'japanese', 'いみ', 'imi', 'meaning', 'いみをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-18', 'languages', 'japanese', 'ぶんぽう', 'bunpou', 'grammar', 'ぶんぽうをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-19', 'languages', 'japanese', 'かんじ', 'kanji', 'Chinese characters', 'かんじをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-20', 'languages', 'japanese', 'ひらがな', 'hiragana', 'hiragana', 'ひらがなをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-21', 'languages', 'japanese', 'カタカナ', 'katakana', 'katakana', 'カタカナをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-22', 'languages', 'japanese', 'かいわ', 'kaiwa', 'conversation', 'かいわをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-23', 'languages', 'japanese', 'ほんやく', 'hon''yaku', 'translation', 'ほんやくをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('languages-24', 'languages', 'japanese', 'つうやく', 'tsuuyaku', 'interpretation', 'つうやくをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('food', 'japanese', 'Food', 12)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-1', 'food', 'japanese', 'ごはん', 'gohan', 'rice / meal', 'ごはんをたべます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-2', 'food', 'japanese', 'すし', 'sushi', 'sushi', 'すしがすきです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-3', 'food', 'japanese', 'ラーメン', 'raamen', 'ramen', 'ラーメンをください。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-4', 'food', 'japanese', 'パン', 'pan', 'bread', 'パンとコーヒーをのみます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-5', 'food', 'japanese', 'さかな', 'sakana', 'fish', 'さかなをたべません。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-6', 'food', 'japanese', 'やさい', 'yasai', 'vegetables', 'やさいをかいます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-7', 'food', 'japanese', 'たまご', 'tamago', 'egg', 'たまごをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-8', 'food', 'japanese', 'くだもの', 'kudamono', 'fruit', 'くだものをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-9', 'food', 'japanese', 'りんご', 'ringo', 'apple', 'りんごをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-10', 'food', 'japanese', 'みかん', 'mikan', 'mandarin orange', 'みかんをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-11', 'food', 'japanese', 'バナナ', 'banana', 'banana', 'バナナをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-12', 'food', 'japanese', 'ごはんもの', 'gohan mono', 'rice dish', 'ごはんものをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-13', 'food', 'japanese', 'カレー', 'karee', 'curry', 'カレーをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-14', 'food', 'japanese', 'ぎゅうにく', 'gyuuniku', 'beef', 'ぎゅうにくをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-15', 'food', 'japanese', 'とりにく', 'toriniku', 'chicken', 'とりにくをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-16', 'food', 'japanese', 'ぶたにく', 'butaniku', 'pork', 'ぶたにくをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-17', 'food', 'japanese', 'さかなりょうり', 'sakana ryouri', 'fish dish', 'さかなりょうりをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-18', 'food', 'japanese', 'サラダ', 'sarada', 'salad', 'サラダをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-19', 'food', 'japanese', 'スープ', 'suupu', 'soup', 'スープをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-20', 'food', 'japanese', 'ケーキ', 'keeki', 'cake', 'ケーキをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-21', 'food', 'japanese', 'アイスクリーム', 'aisukuriimu', 'ice cream', 'アイスクリームをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-22', 'food', 'japanese', 'あさごはん', 'asagohan', 'breakfast', 'あさごはんをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-23', 'food', 'japanese', 'ひるごはん', 'hirugohan', 'lunch', 'ひるごはんをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('food-24', 'food', 'japanese', 'ばんごはん', 'bangohan', 'dinner', 'ばんごはんをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('drinks', 'japanese', 'Drinks', 13)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-1', 'drinks', 'japanese', 'みず', 'mizu', 'water', 'みずをください。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-2', 'drinks', 'japanese', 'おちゃ', 'ocha', 'tea', 'おちゃをのみます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-3', 'drinks', 'japanese', 'コーヒー', 'koohii', 'coffee', 'コーヒーがすきです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-4', 'drinks', 'japanese', 'ぎゅうにゅう', 'gyuunyuu', 'milk', 'ぎゅうにゅうをかいました。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-5', 'drinks', 'japanese', 'ジュース', 'juusu', 'juice', 'ジュースをのみたいです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-6', 'drinks', 'japanese', 'さけ', 'sake', 'alcohol / sake', 'さけはのみません。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-7', 'drinks', 'japanese', 'ぎゅうにゅう', 'gyuunyuu', 'milk', 'ぎゅうにゅうをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-8', 'drinks', 'japanese', 'ジュース', 'juusu', 'juice', 'ジュースをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-9', 'drinks', 'japanese', 'ビール', 'biiru', 'beer', 'ビールをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-10', 'drinks', 'japanese', 'ワイン', 'wain', 'wine', 'ワインをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-11', 'drinks', 'japanese', 'おさけ', 'osake', 'alcohol or sake', 'おさけをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-12', 'drinks', 'japanese', 'みそしる', 'misoshiru', 'miso soup', 'みそしるをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-13', 'drinks', 'japanese', 'みずいろののみもの', 'mizuiro no nomimono', 'blue drink', 'みずいろののみものをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-14', 'drinks', 'japanese', 'つめたいみず', 'tsumetai mizu', 'cold water', 'つめたいみずをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-15', 'drinks', 'japanese', 'あたたかいおちゃ', 'atatakai ocha', 'hot tea', 'あたたかいおちゃをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-16', 'drinks', 'japanese', 'ココア', 'kokoa', 'cocoa', 'ココアをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-17', 'drinks', 'japanese', 'こうちゃ', 'koucha', 'black tea', 'こうちゃをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-18', 'drinks', 'japanese', 'りょくちゃ', 'ryokucha', 'green tea', 'りょくちゃをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-19', 'drinks', 'japanese', 'ウーロンちゃ', 'uuron cha', 'oolong tea', 'ウーロンちゃをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-20', 'drinks', 'japanese', 'のみもの', 'nomimono', 'drink', 'のみものをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-21', 'drinks', 'japanese', 'いっぱい', 'ippai', 'one cup', 'いっぱいをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-22', 'drinks', 'japanese', 'おかわり', 'okawari', 'refill', 'おかわりをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-23', 'drinks', 'japanese', 'のどがかわきました', 'nodo ga kawakimashita', 'I am thirsty', 'のどがかわきましたをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('drinks-24', 'drinks', 'japanese', 'カフェラテ', 'kaferate', 'cafe latte', 'カフェラテをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('places', 'japanese', 'Places', 14)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-1', 'places', 'japanese', 'いえ', 'ie', 'house', 'いえへかえります。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-2', 'places', 'japanese', 'がっこう', 'gakkou', 'school', 'がっこうにいきます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-3', 'places', 'japanese', 'えき', 'eki', 'station', 'えきはどこですか。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-4', 'places', 'japanese', 'みせ', 'mise', 'shop', 'みせでかいます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-5', 'places', 'japanese', 'レストラン', 'resutoran', 'restaurant', 'レストランでたべます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-6', 'places', 'japanese', 'ホテル', 'hoteru', 'hotel', 'ホテルにとまります。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-7', 'places', 'japanese', 'まち', 'machi', 'town', 'まちをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-8', 'places', 'japanese', 'むら', 'mura', 'village', 'むらをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-9', 'places', 'japanese', 'こうえん', 'kouen', 'park', 'こうえんをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-10', 'places', 'japanese', 'うみ', 'umi', 'sea', 'うみをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-11', 'places', 'japanese', 'かわべ', 'kawabe', 'riverside', 'かわべをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-12', 'places', 'japanese', 'みなと', 'minato', 'port', 'みなとをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-13', 'places', 'japanese', 'みち', 'michi', 'road', 'みちをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-14', 'places', 'japanese', 'まどぐち', 'madoguchi', 'counter window', 'まどぐちをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-15', 'places', 'japanese', 'にしぐち', 'nishiguchi', 'west exit', 'にしぐちをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-16', 'places', 'japanese', 'ひがしぐち', 'higashiguchi', 'east exit', 'ひがしぐちをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-17', 'places', 'japanese', 'いりぐち', 'iriguchi', 'entrance', 'いりぐちをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-18', 'places', 'japanese', 'でぐち', 'deguchi', 'exit', 'でぐちをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-19', 'places', 'japanese', 'ちかく', 'chikaku', 'nearby', 'ちかくをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-20', 'places', 'japanese', 'とおく', 'tooku', 'far away', 'とおくをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-21', 'places', 'japanese', 'まんなか', 'mannaka', 'center', 'まんなかをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-22', 'places', 'japanese', 'となり', 'tonari', 'next to', 'となりをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-23', 'places', 'japanese', 'そば', 'soba', 'beside', 'そばをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('places-24', 'places', 'japanese', 'ばしょ', 'basho', 'place', 'ばしょをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('buildings', 'japanese', 'Buildings', 15)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-1', 'buildings', 'japanese', 'びょういん', 'byouin', 'hospital', 'びょういんへいきます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-2', 'buildings', 'japanese', 'としょかん', 'toshokan', 'library', 'としょかんでほんをよみます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-3', 'buildings', 'japanese', 'デパート', 'depaato', 'department store', 'デパートでふくをかいます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-4', 'buildings', 'japanese', 'ぎんこう', 'ginkou', 'bank', 'ぎんこうはどこですか。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-5', 'buildings', 'japanese', 'ゆうびんきょく', 'yuubinkyoku', 'post office', 'ゆうびんきょくへいきます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-6', 'buildings', 'japanese', 'こうえん', 'kouen', 'park', 'こうえんでともだちにあいます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-7', 'buildings', 'japanese', 'ぎんこう', 'ginkou', 'bank', 'ぎんこうをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-8', 'buildings', 'japanese', 'ゆうびんきょく', 'yuubinkyoku', 'post office', 'ゆうびんきょくをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-9', 'buildings', 'japanese', 'デパート', 'depaato', 'department store', 'デパートをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-10', 'buildings', 'japanese', 'スーパー', 'suupaa', 'supermarket', 'スーパーをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-11', 'buildings', 'japanese', 'コンビニ', 'konbini', 'convenience store', 'コンビニをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-12', 'buildings', 'japanese', 'くうこう', 'kuukou', 'airport', 'くうこうをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-13', 'buildings', 'japanese', 'こうばん', 'kouban', 'police box', 'こうばんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-14', 'buildings', 'japanese', 'びょういんのうけつけ', 'byouin no uketsuke', 'hospital reception', 'びょういんのうけつけをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-15', 'buildings', 'japanese', 'えいがかん', 'eigakan', 'movie theater', 'えいがかんをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-16', 'buildings', 'japanese', 'びじゅつかん', 'bijutsukan', 'art museum', 'びじゅつかんをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-17', 'buildings', 'japanese', 'はくぶつかん', 'hakubutsukan', 'museum', 'はくぶつかんをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-18', 'buildings', 'japanese', 'だいがく', 'daigaku', 'university', 'だいがくをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-19', 'buildings', 'japanese', 'こうこう', 'koukou', 'high school', 'こうこうをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-20', 'buildings', 'japanese', 'いんしょくてん', 'inshokuten', 'eating place', 'いんしょくてんをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-21', 'buildings', 'japanese', 'じむしょ', 'jimusho', 'office', 'じむしょをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-22', 'buildings', 'japanese', 'りょかん', 'ryokan', 'Japanese inn', 'りょかんをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-23', 'buildings', 'japanese', 'マンション', 'manshon', 'apartment building', 'マンションをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('buildings-24', 'buildings', 'japanese', 'たてもの', 'tatemono', 'building', 'たてものをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('transportation', 'japanese', 'Transportation', 16)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-1', 'transportation', 'japanese', 'でんしゃ', 'densha', 'train', 'でんしゃでいきます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-2', 'transportation', 'japanese', 'バス', 'basu', 'bus', 'バスよりでんしゃがはやいです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-3', 'transportation', 'japanese', 'タクシー', 'takushii', 'taxi', 'タクシーをよびます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-4', 'transportation', 'japanese', 'くるま', 'kuruma', 'car', 'くるまでがっこうへいきます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-5', 'transportation', 'japanese', 'じてんしゃ', 'jitensha', 'bicycle', 'じてんしゃにのります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-6', 'transportation', 'japanese', 'ひこうき', 'hikouki', 'airplane', 'ひこうきでにほんへいきます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-7', 'transportation', 'japanese', 'でんしゃ', 'densha', 'train', 'でんしゃをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-8', 'transportation', 'japanese', 'ひこうき', 'hikouki', 'airplane', 'ひこうきをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-9', 'transportation', 'japanese', 'じてんしゃ', 'jitensha', 'bicycle', 'じてんしゃをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-10', 'transportation', 'japanese', 'ふね', 'fune', 'boat', 'ふねをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-11', 'transportation', 'japanese', 'しんかんせん', 'shinkansen', 'bullet train', 'しんかんせんをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-12', 'transportation', 'japanese', 'ちかてつ', 'chikatetsu', 'subway', 'ちかてつをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-13', 'transportation', 'japanese', 'あるきます', 'arukimasu', 'to walk', 'あるきますをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-14', 'transportation', 'japanese', 'とまります', 'tomarimasu', 'to stop', 'とまりますをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-15', 'transportation', 'japanese', 'のります', 'norimasu', 'to ride', 'のりますをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-16', 'transportation', 'japanese', 'おります', 'orimasu', 'to get off', 'おりますをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-17', 'transportation', 'japanese', 'しゅっぱつ', 'shuppatsu', 'departure', 'しゅっぱつをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-18', 'transportation', 'japanese', 'とうちゃく', 'touchaku', 'arrival', 'とうちゃくをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-19', 'transportation', 'japanese', 'きっぷ', 'kippu', 'ticket', 'きっぷをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-20', 'transportation', 'japanese', 'ていきけん', 'teikiken', 'commuter pass', 'ていきけんをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-21', 'transportation', 'japanese', 'うんてん', 'unten', 'driving', 'うんてんをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-22', 'transportation', 'japanese', 'バスてい', 'basutei', 'bus stop', 'バスていをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-23', 'transportation', 'japanese', 'ホーム', 'hoomu', 'platform', 'ホームをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('transportation-24', 'transportation', 'japanese', 'ターミナル', 'taaminaru', 'terminal', 'ターミナルをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('everyday-objects', 'japanese', 'Everyday Objects', 17)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-1', 'everyday-objects', 'japanese', 'ほん', 'hon', 'book', 'これはほんです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-2', 'everyday-objects', 'japanese', 'ペン', 'pen', 'pen', 'ペンでかきます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-3', 'everyday-objects', 'japanese', 'かばん', 'kaban', 'bag', 'かばんはつくえのうえです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-4', 'everyday-objects', 'japanese', 'かさ', 'kasa', 'umbrella', 'あめですからかさをもちます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-5', 'everyday-objects', 'japanese', 'でんわ', 'denwa', 'phone', 'でんわでともだちとはなします。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-6', 'everyday-objects', 'japanese', 'とけい', 'tokei', 'watch / clock', 'とけいをみます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-7', 'everyday-objects', 'japanese', 'けいたい', 'keitai', 'mobile phone', 'けいたいをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-8', 'everyday-objects', 'japanese', 'スマホ', 'sumaho', 'smartphone', 'スマホをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-9', 'everyday-objects', 'japanese', 'さいふ', 'saifu', 'wallet', 'さいふをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-10', 'everyday-objects', 'japanese', 'かぎ', 'kagi', 'key', 'かぎをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-11', 'everyday-objects', 'japanese', 'めがね', 'megane', 'glasses', 'めがねをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-12', 'everyday-objects', 'japanese', 'とけい', 'tokei', 'watch or clock', 'とけいをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-13', 'everyday-objects', 'japanese', 'テレビ', 'terebi', 'television', 'テレビをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-14', 'everyday-objects', 'japanese', 'れいぞうこ', 'reizouko', 'refrigerator', 'れいぞうこをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-15', 'everyday-objects', 'japanese', 'つくえのうえ', 'tsukue no ue', 'on the desk', 'つくえのうえをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-16', 'everyday-objects', 'japanese', 'かみ', 'kami', 'paper', 'かみをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-17', 'everyday-objects', 'japanese', 'えんぴつ', 'enpitsu', 'pencil', 'えんぴつをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-18', 'everyday-objects', 'japanese', 'けしごむ', 'keshigomu', 'eraser', 'けしごむをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-19', 'everyday-objects', 'japanese', 'ハサミ', 'hasami', 'scissors', 'ハサミをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-20', 'everyday-objects', 'japanese', 'てがみ', 'tegami', 'letter', 'てがみをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-21', 'everyday-objects', 'japanese', 'しゃしん', 'shashin', 'photo', 'しゃしんをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-22', 'everyday-objects', 'japanese', 'でんち', 'denchi', 'battery', 'でんちをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-23', 'everyday-objects', 'japanese', 'ふくろ', 'fukuro', 'bag or sack', 'ふくろをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('everyday-objects-24', 'everyday-objects', 'japanese', 'にもつ', 'nimotsu', 'baggage', 'にもつをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('clothing', 'japanese', 'Clothing', 18)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-1', 'clothing', 'japanese', 'シャツ', 'shatsu', 'shirt', 'しろいシャツです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-2', 'clothing', 'japanese', 'くつ', 'kutsu', 'shoes', 'あたらしいくつをかいました。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-3', 'clothing', 'japanese', 'ぼうし', 'boushi', 'hat', 'ぼうしをかぶります。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-4', 'clothing', 'japanese', 'ズボン', 'zubon', 'trousers', 'ズボンはやすいです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-5', 'clothing', 'japanese', 'コート', 'kooto', 'coat', 'ふゆはコートをきます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-6', 'clothing', 'japanese', 'セーター', 'seetaa', 'sweater', 'セーターはあたたかいです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-7', 'clothing', 'japanese', 'くつ', 'kutsu', 'shoes', 'くつをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-8', 'clothing', 'japanese', 'くつした', 'kutsushita', 'socks', 'くつしたをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-9', 'clothing', 'japanese', 'ぼうし', 'boushi', 'hat', 'ぼうしをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-10', 'clothing', 'japanese', 'コート', 'kooto', 'coat', 'コートをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-11', 'clothing', 'japanese', 'ジャケット', 'jaketto', 'jacket', 'ジャケットをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-12', 'clothing', 'japanese', 'ズボン', 'zubon', 'trousers', 'ズボンをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-13', 'clothing', 'japanese', 'スカート', 'sukaato', 'skirt', 'スカートをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-14', 'clothing', 'japanese', 'セーター', 'seetaa', 'sweater', 'セーターをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-15', 'clothing', 'japanese', 'ドレス', 'doresu', 'dress', 'ドレスをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-16', 'clothing', 'japanese', 'てぶくろ', 'tebukuro', 'gloves', 'てぶくろをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-17', 'clothing', 'japanese', 'マフラー', 'mafuraa', 'scarf', 'マフラーをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-18', 'clothing', 'japanese', 'ベルト', 'beruto', 'belt', 'ベルトをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-19', 'clothing', 'japanese', 'パジャマ', 'pajama', 'pajamas', 'パジャマをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-20', 'clothing', 'japanese', 'サイズ', 'saizu', 'size', 'サイズをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-21', 'clothing', 'japanese', 'きがえます', 'kigaemasu', 'to change clothes', 'きがえますをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-22', 'clothing', 'japanese', 'きます', 'kimasu', 'to wear', 'きますをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-23', 'clothing', 'japanese', 'はきます', 'hakimasu', 'to put on lower-body clothing', 'はきますをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('clothing-24', 'clothing', 'japanese', 'ぬぎます', 'nugimasu', 'to take off clothing', 'ぬぎますをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('weather', 'japanese', 'Weather', 19)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-1', 'weather', 'japanese', 'はれ', 'hare', 'sunny', 'きょうははれです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-2', 'weather', 'japanese', 'あめ', 'ame', 'rain', 'あめがふっています。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-3', 'weather', 'japanese', 'ゆき', 'yuki', 'snow', 'ゆきはしろいです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-4', 'weather', 'japanese', 'くもり', 'kumori', 'cloudy', 'あしたはくもりです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-5', 'weather', 'japanese', 'あつい', 'atsui', 'hot', 'きょうはあついです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-6', 'weather', 'japanese', 'さむい', 'samui', 'cold', 'ふゆはさむいです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-7', 'weather', 'japanese', 'てんき', 'tenki', 'weather', 'てんきをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-8', 'weather', 'japanese', 'いいてんき', 'ii tenki', 'good weather', 'いいてんきをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-9', 'weather', 'japanese', 'わるいてんき', 'warui tenki', 'bad weather', 'わるいてんきをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-10', 'weather', 'japanese', 'かぜ', 'kaze', 'wind', 'かぜをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-11', 'weather', 'japanese', 'たいふう', 'taifuu', 'typhoon', 'たいふうをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-12', 'weather', 'japanese', 'あたたかい', 'atatakai', 'warm', 'あたたかいをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-13', 'weather', 'japanese', 'すずしい', 'suzushii', 'cool', 'すずしいをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-14', 'weather', 'japanese', 'つめたい', 'tsumetai', 'cold to the touch', 'つめたいをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-15', 'weather', 'japanese', 'むしあつい', 'mushiatsui', 'humid and hot', 'むしあついをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-16', 'weather', 'japanese', 'くも', 'kumo', 'cloud', 'くもをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-17', 'weather', 'japanese', 'はれる', 'hareru', 'to clear up', 'はれるをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-18', 'weather', 'japanese', 'ふります', 'furimasu', 'to fall from the sky', 'ふりますをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-19', 'weather', 'japanese', 'ゆきがふります', 'yuki ga furimasu', 'snow falls', 'ゆきがふりますをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-20', 'weather', 'japanese', 'あめがふります', 'ame ga furimasu', 'rain falls', 'あめがふりますをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-21', 'weather', 'japanese', 'そら', 'sora', 'sky', 'そらをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-22', 'weather', 'japanese', 'にじ', 'niji', 'rainbow', 'にじをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-23', 'weather', 'japanese', 'きおん', 'kion', 'temperature', 'きおんをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('weather-24', 'weather', 'japanese', 'よほう', 'yohou', 'forecast', 'よほうをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('nature', 'japanese', 'Nature', 20)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-1', 'nature', 'japanese', 'やま', 'yama', 'mountain', 'やまはたかいです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-2', 'nature', 'japanese', 'かわ', 'kawa', 'river', 'かわのみずはきれいです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-3', 'nature', 'japanese', 'そら', 'sora', 'sky', 'そらはあおいです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-4', 'nature', 'japanese', 'はな', 'hana', 'flower', 'はなをみます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-5', 'nature', 'japanese', 'き', 'ki', 'tree', 'おおきいきがあります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-6', 'nature', 'japanese', 'うみ', 'umi', 'sea', 'うみへいきたいです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-7', 'nature', 'japanese', 'き', 'ki', 'tree', 'きをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-8', 'nature', 'japanese', 'もり', 'mori', 'forest', 'もりをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-9', 'nature', 'japanese', 'はな', 'hana', 'flower', 'はなをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-10', 'nature', 'japanese', 'くさ', 'kusa', 'grass', 'くさをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-11', 'nature', 'japanese', 'かわ', 'kawa', 'river', 'かわをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-12', 'nature', 'japanese', 'いし', 'ishi', 'stone', 'いしをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-13', 'nature', 'japanese', 'つき', 'tsuki', 'moon', 'つきをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-14', 'nature', 'japanese', 'たいよう', 'taiyou', 'sun', 'たいようをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-15', 'nature', 'japanese', 'ほし', 'hoshi', 'star', 'ほしをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-16', 'nature', 'japanese', 'そら', 'sora', 'sky', 'そらをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-17', 'nature', 'japanese', 'うみ', 'umi', 'sea', 'うみをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-18', 'nature', 'japanese', 'やま', 'yama', 'mountain', 'やまをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-19', 'nature', 'japanese', 'どうぶつ', 'doubutsu', 'animal', 'どうぶつをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-20', 'nature', 'japanese', 'とり', 'tori', 'bird', 'とりをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-21', 'nature', 'japanese', 'いぬ', 'inu', 'dog', 'いぬをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-22', 'nature', 'japanese', 'ねこ', 'neko', 'cat', 'ねこをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-23', 'nature', 'japanese', 'さかな', 'sakana', 'fish', 'さかなをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('nature-24', 'nature', 'japanese', 'むし', 'mushi', 'insect', 'むしをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('body-parts', 'japanese', 'Body Parts', 21)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-1', 'body-parts', 'japanese', 'あたま', 'atama', 'head', 'あたまがいたいです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-2', 'body-parts', 'japanese', 'め', 'me', 'eye', 'めでみます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-3', 'body-parts', 'japanese', 'みみ', 'mimi', 'ear', 'みみでききます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-4', 'body-parts', 'japanese', 'て', 'te', 'hand', 'てでかきます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-5', 'body-parts', 'japanese', 'あし', 'ashi', 'leg / foot', 'あしがつかれました。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-6', 'body-parts', 'japanese', 'くち', 'kuchi', 'mouth', 'くちをあけてください。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-7', 'body-parts', 'japanese', 'あたま', 'atama', 'head', 'あたまをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-8', 'body-parts', 'japanese', 'かお', 'kao', 'face', 'かおをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-9', 'body-parts', 'japanese', 'め', 'me', 'eye', 'めをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-10', 'body-parts', 'japanese', 'みみ', 'mimi', 'ear', 'みみをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-11', 'body-parts', 'japanese', 'くち', 'kuchi', 'mouth', 'くちをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-12', 'body-parts', 'japanese', 'は', 'ha', 'tooth', 'はをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-13', 'body-parts', 'japanese', 'て', 'te', 'hand', 'てをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-14', 'body-parts', 'japanese', 'あし', 'ashi', 'leg or foot', 'あしをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-15', 'body-parts', 'japanese', 'うで', 'ude', 'arm', 'うでをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-16', 'body-parts', 'japanese', 'ゆび', 'yubi', 'finger', 'ゆびをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-17', 'body-parts', 'japanese', 'おなか', 'onaka', 'stomach', 'おなかをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-18', 'body-parts', 'japanese', 'せなか', 'senaka', 'back', 'せなかをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-19', 'body-parts', 'japanese', 'のど', 'nodo', 'throat', 'のどをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-20', 'body-parts', 'japanese', 'はな', 'hana', 'nose', 'はなをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-21', 'body-parts', 'japanese', 'からだ', 'karada', 'body', 'からだをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-22', 'body-parts', 'japanese', 'かみ', 'kami', 'hair', 'かみをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-23', 'body-parts', 'japanese', 'こころ', 'kokoro', 'heart or mind', 'こころをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('body-parts-24', 'body-parts', 'japanese', 'びょうき', 'byouki', 'illness', 'びょうきをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('colors', 'japanese', 'Colors', 22)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-1', 'colors', 'japanese', 'しろ', 'shiro', 'white', 'しろいシャツです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-2', 'colors', 'japanese', 'くろ', 'kuro', 'black', 'くろいくつです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-3', 'colors', 'japanese', 'あか', 'aka', 'red', 'あかいバッグです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-4', 'colors', 'japanese', 'あお', 'ao', 'blue', 'あおいそらです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-5', 'colors', 'japanese', 'みどり', 'midori', 'green', 'みどりのきです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-6', 'colors', 'japanese', 'きいろ', 'kiiro', 'yellow', 'きいろいはなです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-7', 'colors', 'japanese', 'あか', 'aka', 'red', 'あかをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-8', 'colors', 'japanese', 'あお', 'ao', 'blue', 'あおをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-9', 'colors', 'japanese', 'きいろ', 'kiiro', 'yellow', 'きいろをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-10', 'colors', 'japanese', 'みどり', 'midori', 'green', 'みどりをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-11', 'colors', 'japanese', 'しろ', 'shiro', 'white', 'しろをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-12', 'colors', 'japanese', 'くろ', 'kuro', 'black', 'くろをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-13', 'colors', 'japanese', 'ちゃいろ', 'chairo', 'brown', 'ちゃいろをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-14', 'colors', 'japanese', 'むらさき', 'murasaki', 'purple', 'むらさきをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-15', 'colors', 'japanese', 'ピンク', 'pinku', 'pink', 'ピンクをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-16', 'colors', 'japanese', 'オレンジ', 'orenji', 'orange', 'オレンジをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-17', 'colors', 'japanese', 'はいいろ', 'haiiro', 'gray', 'はいいろをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-18', 'colors', 'japanese', 'こんいろ', 'koniro', 'navy blue', 'こんいろをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-19', 'colors', 'japanese', 'きんいろ', 'kiniro', 'gold color', 'きんいろをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-20', 'colors', 'japanese', 'ぎんいろ', 'giniro', 'silver color', 'ぎんいろをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-21', 'colors', 'japanese', 'いろ', 'iro', 'color', 'いろをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-22', 'colors', 'japanese', 'カラフル', 'karafuru', 'colorful', 'カラフルをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-23', 'colors', 'japanese', 'うすい', 'usui', 'light or pale', 'うすいをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('colors-24', 'colors', 'japanese', 'こい', 'koi', 'dark or deep', 'こいをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('basic-verbs', 'japanese', 'Basic Verbs', 23)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-1', 'basic-verbs', 'japanese', 'たべます', 'tabemasu', 'eat', 'ラーメンをたべます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-2', 'basic-verbs', 'japanese', 'のみます', 'nomimasu', 'drink', 'みずをのみます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-3', 'basic-verbs', 'japanese', 'いきます', 'ikimasu', 'go', 'がっこうにいきます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-4', 'basic-verbs', 'japanese', 'きます', 'kimasu', 'come', 'ともだちがきます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-5', 'basic-verbs', 'japanese', 'みます', 'mimasu', 'see / watch', 'テレビをみます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-6', 'basic-verbs', 'japanese', 'はなします', 'hanashimasu', 'speak', 'にほんごではなします。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-7', 'basic-verbs', 'japanese', 'あります', 'arimasu', 'to exist for things', 'ありますをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-8', 'basic-verbs', 'japanese', 'います', 'imasu', 'to exist for living things', 'いますをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-9', 'basic-verbs', 'japanese', 'おきます', 'okimasu', 'to wake up', 'おきますをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-10', 'basic-verbs', 'japanese', 'ねます', 'nemasu', 'to sleep', 'ねますをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-11', 'basic-verbs', 'japanese', 'はじまります', 'hajimarimasu', 'to begin', 'はじまりますをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-12', 'basic-verbs', 'japanese', 'おわります', 'owarimasu', 'to end', 'おわりますをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-13', 'basic-verbs', 'japanese', 'まちます', 'machimasu', 'to wait', 'まちますをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-14', 'basic-verbs', 'japanese', 'とります', 'torimasu', 'to take', 'とりますをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-15', 'basic-verbs', 'japanese', 'もちます', 'mochimasu', 'to hold', 'もちますをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-16', 'basic-verbs', 'japanese', 'あけます', 'akemasu', 'to open', 'あけますをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-17', 'basic-verbs', 'japanese', 'しめます', 'shimemasu', 'to close', 'しめますをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-18', 'basic-verbs', 'japanese', 'すわります', 'suwarimasu', 'to sit', 'すわりますをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-19', 'basic-verbs', 'japanese', 'たちます', 'tachimasu', 'to stand up', 'たちますをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-20', 'basic-verbs', 'japanese', 'はいります', 'hairimasu', 'to enter', 'はいりますをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-21', 'basic-verbs', 'japanese', 'でます', 'demasu', 'to leave', 'でますをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-22', 'basic-verbs', 'japanese', 'ならいます', 'naraimasu', 'to learn', 'ならいますをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-23', 'basic-verbs', 'japanese', 'おしえます', 'oshiemasu', 'to teach', 'おしえますをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-24', 'basic-verbs', 'japanese', 'ききます', 'kikimasu', 'to listen or ask', 'ききますをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-25', 'basic-verbs', 'japanese', 'わかります', 'wakarimasu', 'to understand', 'わかりますをつかったれんしゅうをします。', 24)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-verbs-26', 'basic-verbs', 'japanese', 'つかいます', 'tsukaimasu', 'to use', 'つかいますをつかったれんしゅうをします。', 25)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('basic-adjectives', 'japanese', 'Basic Adjectives', 24)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-1', 'basic-adjectives', 'japanese', 'おいしい', 'oishii', 'delicious', 'このすしはおいしいです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-2', 'basic-adjectives', 'japanese', 'きれい', 'kirei', 'beautiful / clean', 'このへやはきれいです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-3', 'basic-adjectives', 'japanese', 'しずか', 'shizuka', 'quiet', 'としょかんはしずかです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-4', 'basic-adjectives', 'japanese', 'べんり', 'benri', 'convenient', 'スマホはべんりです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-5', 'basic-adjectives', 'japanese', 'おおきい', 'ookii', 'big', 'おおきいやまです。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-6', 'basic-adjectives', 'japanese', 'ちいさい', 'chiisai', 'small', 'ちいさいいぬです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-7', 'basic-adjectives', 'japanese', 'たのしい', 'tanoshii', 'fun', 'たのしいをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-8', 'basic-adjectives', 'japanese', 'かなしい', 'kanashii', 'sad', 'かなしいをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-9', 'basic-adjectives', 'japanese', 'いそがしい', 'isogashii', 'busy', 'いそがしいをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-10', 'basic-adjectives', 'japanese', 'やさしい', 'yasashii', 'kind or easy', 'やさしいをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-11', 'basic-adjectives', 'japanese', 'むずかしい', 'muzukashii', 'difficult', 'むずかしいをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-12', 'basic-adjectives', 'japanese', 'うれしい', 'ureshii', 'happy', 'うれしいをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-13', 'basic-adjectives', 'japanese', 'こわい', 'kowai', 'scary', 'こわいをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-14', 'basic-adjectives', 'japanese', 'ねむい', 'nemui', 'sleepy', 'ねむいをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-15', 'basic-adjectives', 'japanese', 'いたい', 'itai', 'painful', 'いたいをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-16', 'basic-adjectives', 'japanese', 'あかるい', 'akarui', 'bright', 'あかるいをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-17', 'basic-adjectives', 'japanese', 'くらい', 'kurai', 'dark', 'くらいをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-18', 'basic-adjectives', 'japanese', 'しずかな', 'shizuka na', 'quiet', 'しずかなをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-19', 'basic-adjectives', 'japanese', 'にぎやかな', 'nigiyaka na', 'lively', 'にぎやかなをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-20', 'basic-adjectives', 'japanese', 'べんりな', 'benri na', 'convenient', 'べんりなをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-21', 'basic-adjectives', 'japanese', 'ふべんな', 'fuben na', 'inconvenient', 'ふべんなをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-22', 'basic-adjectives', 'japanese', 'げんきな', 'genki na', 'healthy or lively', 'げんきなをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-23', 'basic-adjectives', 'japanese', 'ひまな', 'hima na', 'free, not busy', 'ひまなをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-adjectives-24', 'basic-adjectives', 'japanese', 'だいじな', 'daiji na', 'important', 'だいじなをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('shopping-words', 'japanese', 'Shopping Words', 25)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-1', 'shopping-words', 'japanese', 'これ', 'kore', 'this', 'これをください。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-2', 'shopping-words', 'japanese', 'それ', 'sore', 'that', 'それはたかいです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-3', 'shopping-words', 'japanese', 'どれ', 'dore', 'which', 'どれがいいですか。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-4', 'shopping-words', 'japanese', 'ください', 'kudasai', 'please give me', 'みずをください。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-5', 'shopping-words', 'japanese', 'カード', 'kaado', 'card', 'カードはだいじょうぶですか。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-6', 'shopping-words', 'japanese', 'げんきん', 'genkin', 'cash', 'げんきんでください。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-7', 'shopping-words', 'japanese', 'これ', 'kore', 'this', 'これをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-8', 'shopping-words', 'japanese', 'それ', 'sore', 'that near you', 'それをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-9', 'shopping-words', 'japanese', 'あれ', 'are', 'that over there', 'あれをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-10', 'shopping-words', 'japanese', 'どれ', 'dore', 'which one', 'どれをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-11', 'shopping-words', 'japanese', 'こちら', 'kochira', 'this way or this one politely', 'こちらをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-12', 'shopping-words', 'japanese', 'そちら', 'sochira', 'that way or that one politely', 'そちらをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-13', 'shopping-words', 'japanese', 'あちら', 'achira', 'that way over there politely', 'あちらをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-14', 'shopping-words', 'japanese', 'どちら', 'dochira', 'which way or which one politely', 'どちらをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-15', 'shopping-words', 'japanese', 'みせます', 'misemasu', 'to show', 'みせますをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-16', 'shopping-words', 'japanese', 'ためします', 'tameshimasu', 'to try', 'ためしますをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-17', 'shopping-words', 'japanese', 'えらびます', 'erabimasu', 'to choose', 'えらびますをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-18', 'shopping-words', 'japanese', 'かわいい', 'kawaii', 'cute', 'かわいいをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-19', 'shopping-words', 'japanese', 'きれい', 'kirei', 'pretty or clean', 'きれいをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-20', 'shopping-words', 'japanese', 'サイズがありますか', 'saizu ga arimasu ka', 'do you have this size', 'サイズがありますかをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-21', 'shopping-words', 'japanese', 'ほかのいろ', 'hoka no iro', 'another color', 'ほかのいろをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-22', 'shopping-words', 'japanese', 'うりば', 'uriba', 'sales floor', 'うりばをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-23', 'shopping-words', 'japanese', 'おすすめ', 'osusume', 'recommendation', 'おすすめをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('shopping-words-24', 'shopping-words', 'japanese', 'にんき', 'ninki', 'popular', 'にんきをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('direction-words', 'japanese', 'Direction Words', 26)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-1', 'direction-words', 'japanese', 'みぎ', 'migi', 'right', 'みぎです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-2', 'direction-words', 'japanese', 'ひだり', 'hidari', 'left', 'ひだりへまがってください。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-3', 'direction-words', 'japanese', 'まっすぐ', 'massugu', 'straight', 'まっすぐです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-4', 'direction-words', 'japanese', 'うえ', 'ue', 'up', 'うえをみてください。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-5', 'direction-words', 'japanese', 'した', 'shita', 'down', 'したにあります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-6', 'direction-words', 'japanese', 'となり', 'tonari', 'next to', 'えきのとなりです。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-7', 'direction-words', 'japanese', 'まっすぐ', 'massugu', 'straight ahead', 'まっすぐをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-8', 'direction-words', 'japanese', 'ひだり', 'hidari', 'left', 'ひだりをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-9', 'direction-words', 'japanese', 'みぎ', 'migi', 'right', 'みぎをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-10', 'direction-words', 'japanese', 'うえ', 'ue', 'up', 'うえをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-11', 'direction-words', 'japanese', 'した', 'shita', 'down', 'したをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-12', 'direction-words', 'japanese', 'まえ', 'mae', 'front', 'まえをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-13', 'direction-words', 'japanese', 'うしろ', 'ushiro', 'behind', 'うしろをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-14', 'direction-words', 'japanese', 'なか', 'naka', 'inside', 'なかをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-15', 'direction-words', 'japanese', 'そと', 'soto', 'outside', 'そとをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-16', 'direction-words', 'japanese', 'きた', 'kita', 'north', 'きたをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-17', 'direction-words', 'japanese', 'みなみ', 'minami', 'south', 'みなみをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-18', 'direction-words', 'japanese', 'ひがし', 'higashi', 'east', 'ひがしをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-19', 'direction-words', 'japanese', 'にし', 'nishi', 'west', 'にしをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-20', 'direction-words', 'japanese', 'となり', 'tonari', 'next to', 'となりをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-21', 'direction-words', 'japanese', 'ちかく', 'chikaku', 'near', 'ちかくをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-22', 'direction-words', 'japanese', 'とおい', 'tooi', 'far', 'とおいをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-23', 'direction-words', 'japanese', 'むこう', 'mukou', 'the other side', 'むこうをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('direction-words-24', 'direction-words', 'japanese', 'あいだ', 'aida', 'between', 'あいだをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('school-words', 'japanese', 'School Words', 27)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-1', 'school-words', 'japanese', 'じゅぎょう', 'jugyou', 'class', 'じゅぎょうがはじまります。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-2', 'school-words', 'japanese', 'しゅくだい', 'shukudai', 'homework', 'しゅくだいをします。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-3', 'school-words', 'japanese', 'ノート', 'nooto', 'notebook', 'ノートにかきます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-4', 'school-words', 'japanese', 'つくえ', 'tsukue', 'desk', 'つくえのうえにほんがあります。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-5', 'school-words', 'japanese', 'いす', 'isu', 'chair', 'いすにすわります。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-6', 'school-words', 'japanese', 'れんしゅう', 'renshuu', 'practice', 'まいにちれんしゅうします。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-7', 'school-words', 'japanese', 'がっこう', 'gakkou', 'school', 'がっこうをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-8', 'school-words', 'japanese', 'きょうしつ', 'kyoushitsu', 'classroom', 'きょうしつをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-9', 'school-words', 'japanese', 'せき', 'seki', 'seat', 'せきをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-10', 'school-words', 'japanese', 'くろいた', 'kuroita', 'blackboard', 'くろいたをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-11', 'school-words', 'japanese', 'じゅぎょう', 'jugyou', 'class lesson', 'じゅぎょうをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-12', 'school-words', 'japanese', 'やすみじかん', 'yasumi jikan', 'break time', 'やすみじかんをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-13', 'school-words', 'japanese', 'しけん', 'shiken', 'exam', 'しけんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-14', 'school-words', 'japanese', 'てんすう', 'tensuu', 'score', 'てんすうをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-15', 'school-words', 'japanese', 'せいせき', 'seiseki', 'grade', 'せいせきをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-16', 'school-words', 'japanese', 'そつぎょう', 'sotsugyou', 'graduation', 'そつぎょうをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-17', 'school-words', 'japanese', 'にゅうがく', 'nyuugaku', 'school entrance', 'にゅうがくをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-18', 'school-words', 'japanese', 'たいくかん', 'taikukan', 'gymnasium', 'たいくかんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-19', 'school-words', 'japanese', 'うんどうじょう', 'undoujou', 'school field', 'うんどうじょうをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-20', 'school-words', 'japanese', 'ぶかつ', 'bukatsu', 'club activity', 'ぶかつをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-21', 'school-words', 'japanese', 'がくぶ', 'gakubu', 'faculty', 'がくぶをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-22', 'school-words', 'japanese', 'せんもん', 'senmon', 'specialty', 'せんもんをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-23', 'school-words', 'japanese', 'がくねん', 'gakunen', 'school year', 'がくねんをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('school-words-24', 'school-words', 'japanese', 'ともだち', 'tomodachi', 'friend', 'ともだちをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('house-words', 'japanese', 'House Words', 28)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-1', 'house-words', 'japanese', 'へや', 'heya', 'room', 'へやはしずかです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-2', 'house-words', 'japanese', 'ドア', 'doa', 'door', 'ドアをあけてください。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-3', 'house-words', 'japanese', 'まど', 'mado', 'window', 'まどをしめます。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-4', 'house-words', 'japanese', 'だいどころ', 'daidokoro', 'kitchen', 'だいどころでりょうりします。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-5', 'house-words', 'japanese', 'ベッド', 'beddo', 'bed', 'ベッドでやすみます。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-6', 'house-words', 'japanese', 'でんき', 'denki', 'light / electricity', 'でんきをつけます。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-7', 'house-words', 'japanese', 'へや', 'heya', 'room', 'へやをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-8', 'house-words', 'japanese', 'だいどころ', 'daidokoro', 'kitchen', 'だいどころをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-9', 'house-words', 'japanese', 'おふろ', 'ofuro', 'bath', 'おふろをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-10', 'house-words', 'japanese', 'げんかん', 'genkan', 'entryway', 'げんかんをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-11', 'house-words', 'japanese', 'いま', 'ima', 'living room', 'いまをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-12', 'house-words', 'japanese', 'まど', 'mado', 'window', 'まどをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-13', 'house-words', 'japanese', 'ドア', 'doa', 'door', 'ドアをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-14', 'house-words', 'japanese', 'ゆか', 'yuka', 'floor', 'ゆかをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-15', 'house-words', 'japanese', 'てんじょう', 'tenjou', 'ceiling', 'てんじょうをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-16', 'house-words', 'japanese', 'ベッド', 'beddo', 'bed', 'ベッドをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-17', 'house-words', 'japanese', 'ふとん', 'futon', 'futon bedding', 'ふとんをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-18', 'house-words', 'japanese', 'でんき', 'denki', 'light or electricity', 'でんきをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-19', 'house-words', 'japanese', 'エアコン', 'eakon', 'air conditioner', 'エアコンをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-20', 'house-words', 'japanese', 'せんたくき', 'sentakuki', 'washing machine', 'せんたくきをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-21', 'house-words', 'japanese', 'そうじします', 'souji shimasu', 'to clean', 'そうじしますをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-22', 'house-words', 'japanese', 'せんたくします', 'sentaku shimasu', 'to do laundry', 'せんたくしますをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-23', 'house-words', 'japanese', 'りょうしんのいえ', 'ryoushin no ie', 'parents'' house', 'りょうしんのいえをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('house-words-24', 'house-words', 'japanese', 'ひっこします', 'hikkoshimasu', 'to move house', 'ひっこしますをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('travel-words', 'japanese', 'Travel Words', 29)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-1', 'travel-words', 'japanese', 'きっぷ', 'kippu', 'ticket', 'きっぷをかいます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-2', 'travel-words', 'japanese', 'パスポート', 'pasupooto', 'passport', 'パスポートがあります。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-3', 'travel-words', 'japanese', 'にもつ', 'nimotsu', 'luggage', 'にもつはおもいです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-4', 'travel-words', 'japanese', 'ちず', 'chizu', 'map', 'ちずをみます。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-5', 'travel-words', 'japanese', 'りょこう', 'ryokou', 'trip', 'にほんへりょこうします。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-6', 'travel-words', 'japanese', 'よやく', 'yoyaku', 'reservation', 'ホテルをよやくしました。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-7', 'travel-words', 'japanese', 'りょこう', 'ryokou', 'travel', 'りょこうをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-8', 'travel-words', 'japanese', 'りょこうしゃ', 'ryokousha', 'traveler', 'りょこうしゃをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-9', 'travel-words', 'japanese', 'よやく', 'yoyaku', 'reservation', 'よやくをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-10', 'travel-words', 'japanese', 'ホテルのへや', 'hoteru no heya', 'hotel room', 'ホテルのへやをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-11', 'travel-words', 'japanese', 'パスポート', 'pasupooto', 'passport', 'パスポートをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-12', 'travel-words', 'japanese', 'にもつ', 'nimotsu', 'luggage', 'にもつをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-13', 'travel-words', 'japanese', 'ちず', 'chizu', 'map', 'ちずをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-14', 'travel-words', 'japanese', 'かんこう', 'kankou', 'sightseeing', 'かんこうをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-15', 'travel-words', 'japanese', 'しゃしんをとります', 'shashin o torimasu', 'to take a photo', 'しゃしんをとりますをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-16', 'travel-words', 'japanese', 'のりかえ', 'norikae', 'transfer', 'のりかえをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-17', 'travel-words', 'japanese', 'とうじょうけん', 'toujouken', 'boarding pass', 'とうじょうけんをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-18', 'travel-words', 'japanese', 'しゅっぱつじかん', 'shuppatsu jikan', 'departure time', 'しゅっぱつじかんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-19', 'travel-words', 'japanese', 'とうちゃくじかん', 'touchaku jikan', 'arrival time', 'とうちゃくじかんをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-20', 'travel-words', 'japanese', 'あんない', 'annai', 'guidance', 'あんないをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-21', 'travel-words', 'japanese', 'りょかん', 'ryokan', 'Japanese inn', 'りょかんをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-22', 'travel-words', 'japanese', 'おみやげ', 'omiyage', 'souvenir', 'おみやげをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-23', 'travel-words', 'japanese', 'きっさてん', 'kissaten', 'coffee shop', 'きっさてんをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('travel-words-24', 'travel-words', 'japanese', 'こくない', 'kokunai', 'domestic', 'こくないをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('question-words', 'japanese', 'Question Words', 30)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-1', 'question-words', 'japanese', 'なに', 'nani', 'what', 'これはなにですか。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-2', 'question-words', 'japanese', 'どこ', 'doko', 'where', 'えきはどこですか。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-3', 'question-words', 'japanese', 'だれ', 'dare', 'who', 'あのひとはだれですか。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-4', 'question-words', 'japanese', 'いつ', 'itsu', 'when', 'いついきますか。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-5', 'question-words', 'japanese', 'どう', 'dou', 'how', 'どうですか。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-6', 'question-words', 'japanese', 'どうして', 'doushite', 'why', 'どうしていきますか。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-7', 'question-words', 'japanese', 'なに', 'nani', 'what', 'なにをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-8', 'question-words', 'japanese', 'だれ', 'dare', 'who', 'だれをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-9', 'question-words', 'japanese', 'どこ', 'doko', 'where', 'どこをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-10', 'question-words', 'japanese', 'いつ', 'itsu', 'when', 'いつをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-11', 'question-words', 'japanese', 'どう', 'dou', 'how', 'どうをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-12', 'question-words', 'japanese', 'どうして', 'doushite', 'why', 'どうしてをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-13', 'question-words', 'japanese', 'なぜ', 'naze', 'why', 'なぜをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-14', 'question-words', 'japanese', 'どちら', 'dochira', 'which way', 'どちらをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-15', 'question-words', 'japanese', 'どの', 'dono', 'which', 'どのをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-16', 'question-words', 'japanese', 'どんな', 'donna', 'what kind of', 'どんなをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-17', 'question-words', 'japanese', 'どれくらい', 'dore kurai', 'how much or how long', 'どれくらいをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-18', 'question-words', 'japanese', 'いくつ', 'ikutsu', 'how many or how old', 'いくつをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-19', 'question-words', 'japanese', 'なんにん', 'nan nin', 'how many people', 'なんにんをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-20', 'question-words', 'japanese', 'なんじ', 'nanji', 'what time', 'なんじをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-21', 'question-words', 'japanese', 'なんようび', 'nan youbi', 'what day of the week', 'なんようびをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-22', 'question-words', 'japanese', 'なんがつ', 'nan gatsu', 'what month', 'なんがつをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-23', 'question-words', 'japanese', 'なんにち', 'nan nichi', 'what date', 'なんにちをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('question-words-24', 'question-words', 'japanese', 'どこから', 'doko kara', 'from where', 'どこからをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('common-adverbs', 'japanese', 'Common Adverbs', 31)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-1', 'common-adverbs', 'japanese', 'よく', 'yoku', 'often / well', 'よくにほんごをききます。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-2', 'common-adverbs', 'japanese', 'あまり', 'amari', 'not very', 'あまりさむくないです。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-3', 'common-adverbs', 'japanese', 'すこし', 'sukoshi', 'a little', 'すこしわかります。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-4', 'common-adverbs', 'japanese', 'とても', 'totemo', 'very', 'とてもおいしいです。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-5', 'common-adverbs', 'japanese', 'もう', 'mou', 'already / more', 'もういちどおねがいします。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-6', 'common-adverbs', 'japanese', 'まだ', 'mada', 'not yet / still', 'まだべんきょうしています。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-7', 'common-adverbs', 'japanese', 'よく', 'yoku', 'often or well', 'よくをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-8', 'common-adverbs', 'japanese', 'あまり', 'amari', 'not very', 'あまりをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-9', 'common-adverbs', 'japanese', 'ぜんぜん', 'zenzen', 'not at all', 'ぜんぜんをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-10', 'common-adverbs', 'japanese', 'いつも', 'itsumo', 'always', 'いつもをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-11', 'common-adverbs', 'japanese', 'ときどき', 'tokidoki', 'sometimes', 'ときどきをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-12', 'common-adverbs', 'japanese', 'たいてい', 'taitei', 'usually', 'たいていをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-13', 'common-adverbs', 'japanese', 'たぶん', 'tabun', 'probably', 'たぶんをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-14', 'common-adverbs', 'japanese', 'ほんとうに', 'hontou ni', 'really', 'ほんとうにをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-15', 'common-adverbs', 'japanese', 'もちろん', 'mochiron', 'of course', 'もちろんをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-16', 'common-adverbs', 'japanese', 'いっしょに', 'issho ni', 'together', 'いっしょにをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-17', 'common-adverbs', 'japanese', 'ひとりで', 'hitori de', 'alone', 'ひとりでをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-18', 'common-adverbs', 'japanese', 'たくさん', 'takusan', 'a lot', 'たくさんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-19', 'common-adverbs', 'japanese', 'すこし', 'sukoshi', 'a little', 'すこしをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-20', 'common-adverbs', 'japanese', 'もう', 'mou', 'already or more', 'もうをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-21', 'common-adverbs', 'japanese', 'まだ', 'mada', 'still or not yet', 'まだをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-22', 'common-adverbs', 'japanese', 'すぐに', 'sugu ni', 'immediately', 'すぐにをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-23', 'common-adverbs', 'japanese', 'とても', 'totemo', 'very', 'とてもをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('common-adverbs-24', 'common-adverbs', 'japanese', 'ゆっくり', 'yukkuri', 'slowly', 'ゆっくりをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_categories (id, language_slug, title, sort_order)
values
  ('basic-expressions', 'japanese', 'Basic Expressions', 32)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-1', 'basic-expressions', 'japanese', 'はい', 'hai', 'yes', 'はい、そうです。', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-2', 'basic-expressions', 'japanese', 'いいえ', 'iie', 'no', 'いいえ、ちがいます。', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-3', 'basic-expressions', 'japanese', 'だいじょうぶです', 'daijoubu desu', 'it is okay', 'カードはだいじょうぶです。', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-4', 'basic-expressions', 'japanese', 'すみません', 'sumimasen', 'excuse me / sorry', 'すみません、えきはどこですか。', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-5', 'basic-expressions', 'japanese', 'おねがいします', 'onegaishimasu', 'please', 'もういちどおねがいします。', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-6', 'basic-expressions', 'japanese', 'どういたしまして', 'douitashimashite', 'you are welcome', 'どういたしまして。', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-7', 'basic-expressions', 'japanese', 'はい', 'hai', 'yes', 'はいをつかったれんしゅうをします。', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-8', 'basic-expressions', 'japanese', 'いいえ', 'iie', 'no', 'いいえをつかったれんしゅうをします。', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-9', 'basic-expressions', 'japanese', 'そうです', 'sou desu', 'that is right', 'そうですをつかったれんしゅうをします。', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-10', 'basic-expressions', 'japanese', 'ちがいます', 'chigaimasu', 'that is not correct', 'ちがいますをつかったれんしゅうをします。', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-11', 'basic-expressions', 'japanese', 'そうですね', 'sou desu ne', 'let me see or that''s right', 'そうですねをつかったれんしゅうをします。', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-12', 'basic-expressions', 'japanese', 'どうも', 'doumo', 'thanks or hello', 'どうもをつかったれんしゅうをします。', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-13', 'basic-expressions', 'japanese', 'なるほど', 'naruhodo', 'I see', 'なるほどをつかったれんしゅうをします。', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-14', 'basic-expressions', 'japanese', 'もちろんです', 'mochiron desu', 'of course', 'もちろんですをつかったれんしゅうをします。', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-15', 'basic-expressions', 'japanese', 'たぶんそうです', 'tabun sou desu', 'probably so', 'たぶんそうですをつかったれんしゅうをします。', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-16', 'basic-expressions', 'japanese', 'だめです', 'dame desu', 'it is no good', 'だめですをつかったれんしゅうをします。', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-17', 'basic-expressions', 'japanese', 'いいですよ', 'ii desu yo', 'it is fine', 'いいですよをつかったれんしゅうをします。', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-18', 'basic-expressions', 'japanese', 'しりません', 'shirimasen', 'I do not know', 'しりませんをつかったれんしゅうをします。', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-19', 'basic-expressions', 'japanese', 'わたしも', 'watashi mo', 'me too', 'わたしもをつかったれんしゅうをします。', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-20', 'basic-expressions', 'japanese', 'そうしましょう', 'sou shimashou', 'let''s do that', 'そうしましょうをつかったれんしゅうをします。', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-21', 'basic-expressions', 'japanese', 'きをつけます', 'ki o tsukemasu', 'I will be careful', 'きをつけますをつかったれんしゅうをします。', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-22', 'basic-expressions', 'japanese', 'すごい', 'sugoi', 'amazing', 'すごいをつかったれんしゅうをします。', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-23', 'basic-expressions', 'japanese', 'ほんとうですか', 'hontou desu ka', 'really', 'ほんとうですかをつかったれんしゅうをします。', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_vocab_entries (id, category_id, language_slug, japanese, romaji, english, example, sort_order)
values
  ('basic-expressions-24', 'basic-expressions', 'japanese', 'だいすきです', 'daisuki desu', 'I love it', 'だいすきですをつかったれんしゅうをします。', 23)
on conflict (id) do update set
  japanese = excluded.japanese,
  romaji = excluded.romaji,
  english = excluded.english,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_groups (id, language_slug, title, sort_order)
values
  ('kanji-numbers-money', 'japanese', 'Numbers and Money', 0)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-1', 'kanji-numbers-money', 'japanese', '一', 'ichi', 'one', '一つ', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-2', 'kanji-numbers-money', 'japanese', '二', 'ni', 'two', '二つ', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-3', 'kanji-numbers-money', 'japanese', '三', 'san', 'three', '三人', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-4', 'kanji-numbers-money', 'japanese', '四', 'yon / shi', 'four', '四時', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-5', 'kanji-numbers-money', 'japanese', '五', 'go', 'five', '五日', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-6', 'kanji-numbers-money', 'japanese', '六', 'roku', 'six', '六時', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-7', 'kanji-numbers-money', 'japanese', '七', 'nana / shichi', 'seven', '七人', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-8', 'kanji-numbers-money', 'japanese', '八', 'hachi', 'eight', '八百', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-9', 'kanji-numbers-money', 'japanese', '九', 'kyuu / ku', 'nine', '九時', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-10', 'kanji-numbers-money', 'japanese', '十', 'juu', 'ten', '十円', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-11', 'kanji-numbers-money', 'japanese', '百', 'hyaku', 'hundred', '百円', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-12', 'kanji-numbers-money', 'japanese', '千', 'sen', 'thousand', '千円', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-13', 'kanji-numbers-money', 'japanese', '万', 'man', 'ten thousand', '一万円', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-numbers-money-14', 'kanji-numbers-money', 'japanese', '円', 'en', 'yen / circle', '五百円', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_groups (id, language_slug, title, sort_order)
values
  ('kanji-time-nature', 'japanese', 'Time, Dates, and Nature', 1)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-1', 'kanji-time-nature', 'japanese', '日', 'nichi / hi', 'day / sun', '日本', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-2', 'kanji-time-nature', 'japanese', '月', 'getsu / tsuki', 'month / moon', '月曜日', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-3', 'kanji-time-nature', 'japanese', '火', 'ka / hi', 'fire', '火曜日', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-4', 'kanji-time-nature', 'japanese', '水', 'sui / mizu', 'water', '水曜日', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-5', 'kanji-time-nature', 'japanese', '木', 'moku / ki', 'tree / wood', '木曜日', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-6', 'kanji-time-nature', 'japanese', '金', 'kin / kane', 'gold / money', '金曜日', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-7', 'kanji-time-nature', 'japanese', '土', 'do / tsuchi', 'earth / soil', '土曜日', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-8', 'kanji-time-nature', 'japanese', '年', 'nen / toshi', 'year', '一年', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-9', 'kanji-time-nature', 'japanese', '時', 'ji / toki', 'time / hour', '六時', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-10', 'kanji-time-nature', 'japanese', '分', 'fun / bun', 'minute / divide', '十分', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-11', 'kanji-time-nature', 'japanese', '半', 'han', 'half', '三時半', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-12', 'kanji-time-nature', 'japanese', '今', 'ima / kon', 'now', '今', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-13', 'kanji-time-nature', 'japanese', '週', 'shuu', 'week', '今週', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-14', 'kanji-time-nature', 'japanese', '午', 'go', 'noon', '午後', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-15', 'kanji-time-nature', 'japanese', '毎', 'mai', 'every', '毎日', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-16', 'kanji-time-nature', 'japanese', '曜', 'you', 'day of week', '月曜日', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-17', 'kanji-time-nature', 'japanese', '天', 'ten / ame', 'heaven / sky', '天気', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-18', 'kanji-time-nature', 'japanese', '気', 'ki', 'spirit / energy', '元気', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-19', 'kanji-time-nature', 'japanese', '空', 'sora / kuu', 'sky / empty', '空', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-20', 'kanji-time-nature', 'japanese', '雨', 'ame / u', 'rain', '雨', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-time-nature-21', 'kanji-time-nature', 'japanese', '電', 'den', 'electricity', '電話', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_groups (id, language_slug, title, sort_order)
values
  ('kanji-directions-places', 'japanese', 'Directions, Size, and Locations', 2)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-1', 'kanji-directions-places', 'japanese', '上', 'ue / jou', 'up / above', '上', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-2', 'kanji-directions-places', 'japanese', '下', 'shita / ka', 'down / below', '下', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-3', 'kanji-directions-places', 'japanese', '左', 'hidari / sa', 'left', '左', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-4', 'kanji-directions-places', 'japanese', '右', 'migi / u', 'right', '右', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-5', 'kanji-directions-places', 'japanese', '前', 'mae / zen', 'front / before', '前', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-6', 'kanji-directions-places', 'japanese', '後', 'ushiro / go', 'back / behind', '後', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-7', 'kanji-directions-places', 'japanese', '中', 'naka / chuu', 'inside / middle', '中', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-8', 'kanji-directions-places', 'japanese', '外', 'soto / gai', 'outside', '外', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-9', 'kanji-directions-places', 'japanese', '北', 'kita / hoku', 'north', '北', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-10', 'kanji-directions-places', 'japanese', '南', 'minami / nan', 'south', '南', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-11', 'kanji-directions-places', 'japanese', '東', 'higashi / tou', 'east', '東京', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-12', 'kanji-directions-places', 'japanese', '西', 'nishi / sei', 'west', '西', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-13', 'kanji-directions-places', 'japanese', '大', 'oo / dai', 'big', '大学', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-14', 'kanji-directions-places', 'japanese', '小', 'chiisai / shou', 'small', '小さい', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-15', 'kanji-directions-places', 'japanese', '高', 'takai / kou', 'high / expensive', '高校', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-16', 'kanji-directions-places', 'japanese', '長', 'nagai / chou', 'long / leader', '校長', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-17', 'kanji-directions-places', 'japanese', '多', 'ooi / ta', 'many / much', '多い', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-18', 'kanji-directions-places', 'japanese', '少', 'sukunai / shou', 'few / little', '少し', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-19', 'kanji-directions-places', 'japanese', '国', 'kuni / koku', 'country', '中国', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-20', 'kanji-directions-places', 'japanese', '駅', 'eki', 'station', '駅', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-21', 'kanji-directions-places', 'japanese', '道', 'michi / dou', 'road / path', '道', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-22', 'kanji-directions-places', 'japanese', '校', 'kou', 'school', '学校', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-directions-places-23', 'kanji-directions-places', 'japanese', '店', 'mise / ten', 'shop / store', '店', 22)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_groups (id, language_slug, title, sort_order)
values
  ('kanji-people-relations', 'japanese', 'People and Relationships', 3)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-1', 'kanji-people-relations', 'japanese', '人', 'hito / jin', 'person', '日本人', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-2', 'kanji-people-relations', 'japanese', '子', 'ko / shi', 'child', '子ども', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-3', 'kanji-people-relations', 'japanese', '学', 'gaku / manabu', 'study', '学生', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-4', 'kanji-people-relations', 'japanese', '父', 'chichi / fu', 'father', '父', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-5', 'kanji-people-relations', 'japanese', '母', 'haha / bo', 'mother', '母', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-6', 'kanji-people-relations', 'japanese', '友', 'tomo / yuu', 'friend', '友だち', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-7', 'kanji-people-relations', 'japanese', '女', 'onna / jo', 'woman', '女', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-8', 'kanji-people-relations', 'japanese', '男', 'otoko / dan', 'man', '男', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-9', 'kanji-people-relations', 'japanese', '先', 'saki / sen', 'ahead / before', '先生', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-10', 'kanji-people-relations', 'japanese', '生', 'sei / ikiru', 'life / birth', '学生', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-people-relations-11', 'kanji-people-relations', 'japanese', '名', 'na / mei', 'name', '名前', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_groups (id, language_slug, title, sort_order)
values
  ('kanji-actions', 'japanese', 'Basic Actions and Verbs', 4)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-1', 'kanji-actions', 'japanese', '行', 'iku / kou', 'to go', '行きます', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-2', 'kanji-actions', 'japanese', '来', 'kuru / rai', 'to come', '来ます', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-3', 'kanji-actions', 'japanese', '出', 'deru / shutsu', 'to exit / go out', '出ます', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-4', 'kanji-actions', 'japanese', '入', 'hairu / nyuu', 'to enter', '入ります', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-5', 'kanji-actions', 'japanese', '食', 'taberu / shoku', 'to eat', '食べます', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-6', 'kanji-actions', 'japanese', '飲', 'nomu / in', 'to drink', '飲みます', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-7', 'kanji-actions', 'japanese', '見', 'miru / ken', 'to see / watch', '見ます', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-8', 'kanji-actions', 'japanese', '聞', 'kiku / bun', 'to hear / listen', '聞きます', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-9', 'kanji-actions', 'japanese', '書', 'kaku / sho', 'to write', '書きます', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-10', 'kanji-actions', 'japanese', '話', 'hanasu / wa', 'to speak / talk', '話します', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-11', 'kanji-actions', 'japanese', '読', 'yomu / doku', 'to read', '読みます', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-12', 'kanji-actions', 'japanese', '買', 'kau / bai', 'to buy', '買います', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-13', 'kanji-actions', 'japanese', '立', 'tatsu / ritsu', 'to stand', '立ちます', 12)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-14', 'kanji-actions', 'japanese', '会', 'au / kai', 'to meet', '会います', 13)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-15', 'kanji-actions', 'japanese', '休', 'yasumu / kyuu', 'to rest', '休みます', 14)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-16', 'kanji-actions', 'japanese', '言', 'iu / gen', 'to say', '言います', 15)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-17', 'kanji-actions', 'japanese', '思', 'omou / shi', 'to think', '思います', 16)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-18', 'kanji-actions', 'japanese', '社', 'sha / yashiro', 'company or shrine', '会社', 17)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-19', 'kanji-actions', 'japanese', '作', 'tsukuru / saku', 'to make', '作ります', 18)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-20', 'kanji-actions', 'japanese', '使', 'tsukau / shi', 'to use', '使います', 19)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-21', 'kanji-actions', 'japanese', '知', 'shiru / chi', 'to know', '知っています', 20)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-actions-22', 'kanji-actions', 'japanese', '住', 'sumu / juu', 'to reside / live', '住んでいます', 21)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_groups (id, language_slug, title, sort_order)
values
  ('kanji-objects-environment', 'japanese', 'Environment and Objects', 5)
on conflict (id) do update set
  title = excluded.title,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-1', 'kanji-objects-environment', 'japanese', '山', 'yama / san', 'mountain', '山', 0)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-2', 'kanji-objects-environment', 'japanese', '川', 'kawa / sen', 'river', '川', 1)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-3', 'kanji-objects-environment', 'japanese', '本', 'hon', 'book / source', '本', 2)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-4', 'kanji-objects-environment', 'japanese', '車', 'kuruma / sha', 'car / vehicle', '車', 3)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-5', 'kanji-objects-environment', 'japanese', '語', 'go / kataru', 'language', '日本語', 4)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-6', 'kanji-objects-environment', 'japanese', '何', 'nani / ka', 'what', '何ですか', 5)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-7', 'kanji-objects-environment', 'japanese', '物', 'mono / butsu', 'thing', '食べ物', 6)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-8', 'kanji-objects-environment', 'japanese', '間', 'aida / kan', 'between / interval', '時間', 7)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-9', 'kanji-objects-environment', 'japanese', '白', 'shiro / haku', 'white', '白い', 8)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-10', 'kanji-objects-environment', 'japanese', '新', 'atarashii / shin', 'new', '新しい', 9)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-11', 'kanji-objects-environment', 'japanese', '古', 'furui / ko', 'old', '古い', 10)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_kanji_entries (id, group_id, language_slug, japanese, reading, meaning, example, sort_order)
values
  ('kanji-objects-environment-12', 'kanji-objects-environment', 'japanese', '足', 'ashi / soku', 'leg / foot', '足', 11)
on conflict (id) do update set
  japanese = excluded.japanese,
  reading = excluded.reading,
  meaning = excluded.meaning,
  example = excluded.example,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('sounds-romaji', 'japanese', 'Section 1: Romaji and Japanese Sounds', $json$["Romaji bridge","Vowels","Sound rows","Long sounds","Small pause sounds"]$json$::jsonb, $json$["Repeat the sound","Select the matching sound","Short spoken correction"]$json$::jsonb, 'Learner can hear and repeat the key sound system with stable timing.', 0)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('hiragana', 'japanese', 'Section 2: Hiragana', $json$["46 basic hiragana","Reading practice","Writing awareness"]$json$::jsonb, $json$["Read the row aloud","Read a word","Identify the character"]$json$::jsonb, 'Learner can read the full basic hiragana set with confidence.', 1)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('katakana', 'japanese', 'Section 3: Katakana', $json$["46 basic katakana","Loanword reading","Travel and cafe words"]$json$::jsonb, $json$["Read the word aloud","Match the word to meaning","Select the heard script"]$json$::jsonb, 'Learner can read core katakana words with practical confidence.', 2)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('special-kana', 'japanese', 'Section 4: Kana Special Sounds', $json$["Dakuon","Handakuon","Yoon","Sokuon","Choun"]$json$::jsonb, $json$["Repeat the contrast pair","Spot the sound difference","Read the special-sound word"]$json$::jsonb, 'Learner can handle the special kana timing and sound shifts.', 3)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('numbers', 'japanese', 'Section 5: Numbers', $json$["0 to 100","100 to 10,000","Money","Time","Age","Dates"]$json$::jsonb, $json$["Count aloud","Answer the price","Say the time","Answer the age question"]$json$::jsonb, 'Learner answers practical number prompts accurately and naturally.', 4)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('vocabulary', 'japanese', 'Section 6: Vocabulary', $json$["Core N5 categories","Daily-use words","Phrase-level vocabulary"]$json$::jsonb, $json$["Choose the meaning","Say the target word","Complete the phrase"]$json$::jsonb, 'Learner can use essential words inside simple real-life phrases.', 5)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('particles', 'japanese', 'Section 7: Particles', $json$["は","が","を","に","で","と","の","も"]$json$::jsonb, $json$["Complete the sentence","Say the line aloud","Choose the best particle"]$json$::jsonb, 'Learner uses the most important particles in practical lines.', 6)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('verbs-adjectives', 'japanese', 'Section 8: Verb and Adjective Conjugation', $json$["ます","ません","ました","ませんでした","Dictionary form","Nai form","Ta form","Te form","い-adjectives","な-adjectives"]$json$::jsonb, $json$["Change the form","Repeat the line","Answer in the target form"]$json$::jsonb, 'Learner recognizes and produces the main N5 beginner forms.', 7)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('grammar', 'japanese', 'Section 9: Grammar Patterns', $json$["てください","てもいいです","ています","たいです","がほしいです","ながら","つもりです","から","とおもいます"]$json$::jsonb, $json$["Use the pattern in a sentence","Respond to the prompt","Choose the best completion"]$json$::jsonb, 'Learner can respond with several core N5 sentence patterns.', 8)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('counters', 'japanese', 'Section 10: Counters', $json$["General items","People","Books","Machines","Times","Floors","Age","Animals"]$json$::jsonb, $json$["Count the objects","Answer how many people","Say the correct counter aloud"]$json$::jsonb, 'Learner uses the most common counters with clear structure.', 9)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('kanji', 'japanese', 'Section 11: Kanji', $json$["103 essential kanji","Numbers","Time","People","Actions","Objects"]$json$::jsonb, $json$["Read the kanji word","Match kanji to meaning","Choose the correct reading"]$json$::jsonb, 'Learner recognizes the essential N5 kanji set in useful words.', 10)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('listening', 'japanese', 'Section 12: Listening', $json$["Words","Numbers","Sentences","Mini conversations"]$json$::jsonb, $json$["Listen and choose","Repeat what you heard","Answer the simple follow-up"]$json$::jsonb, 'Learner can catch basic spoken Japanese without relying on heavy text support.', 11)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('reading', 'japanese', 'Section 13: Reading', $json$["Hiragana words","Katakana words","Kanji words","Short sentences","Tiny paragraphs"]$json$::jsonb, $json$["Read aloud","Choose the meaning","Answer a tiny reading question"]$json$::jsonb, 'Learner reads short N5-level Japanese with calm and usable comprehension.', 12)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_sections (id, language_slug, title, coverage, question_types, pass_signal, sort_order)
values
  ('speaking', 'japanese', 'Section 14: Speaking', $json$["Self introduction","Ordering food","Asking directions","Shopping","Daily routine"]$json$::jsonb, $json$["Guided roleplay","Prompt response","Integrated conversation task"]$json$::jsonb, 'Learner completes the final N5 speaking loop across real-life scenarios.', 13)
on conflict (id) do update set
  title = excluded.title,
  coverage = excluded.coverage,
  question_types = excluded.question_types,
  pass_signal = excluded.pass_signal,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-sound-1', 'japanese', 'sounds-romaji', 'Vowel order', 'Say the five Japanese vowels in the correct order.', 'spoken response', $json$[]$json$::jsonb, 'a, i, u, e, o', 'The basic vowel line is always spoken in this order and becomes the foundation for later sound rows.', 0)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-sound-2', 'japanese', 'sounds-romaji', 'Consonant row rhythm', 'Which row matches the ka-line?', 'multiple choice', $json$["sa, shi, su, se, so","ka, ki, ku, ke, ko","ta, chi, tsu, te, to"]$json$::jsonb, 'ka, ki, ku, ke, ko', 'The ka-row keeps the same vowel order while the initial consonant changes to k.', 1)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-sound-3', 'japanese', 'sounds-romaji', 'Long vowel awareness', 'In a speaking drill, what should you do with a long vowel?', 'short answer', $json$[]$json$::jsonb, 'Hold it a little longer without breaking the rhythm.', 'Long vowels change meaning, so the learner should lengthen them smoothly rather than clipping them short.', 2)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-hiragana-1', 'japanese', 'hiragana', 'Basic script recall', 'Read this hiragana aloud: あ', 'spoken response', $json$[]$json$::jsonb, 'a', 'あ is the first hiragana and represents the vowel sound a.', 3)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-hiragana-2', 'japanese', 'hiragana', 'Word reading', 'What is the reading of さくら?', 'short answer', $json$[]$json$::jsonb, 'sakura', 'The learner should connect individual hiragana sounds into one natural word rather than reading character by character.', 4)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-hiragana-3', 'japanese', 'hiragana', 'Character recognition', 'Which hiragana is read as ''ne''?', 'multiple choice', $json$["れ","ぬ","ね"]$json$::jsonb, 'ね', 'Recognizing common kana quickly is essential before moving into phrases and roleplay.', 5)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-katakana-1', 'japanese', 'katakana', 'Loanword reading', 'Read this katakana word aloud: コーヒー', 'spoken response', $json$[]$json$::jsonb, 'koohii', 'The long vowels matter here. The learner should stretch the middle and final vowels naturally.', 6)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-katakana-2', 'japanese', 'katakana', 'Travel word recognition', 'Which word means ''taxi''?', 'multiple choice', $json$["タクシー","ホテル","バス"]$json$::jsonb, 'タクシー', 'Katakana often appears in travel and daily borrowed words, so this is a high-value recognition item.', 7)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-katakana-3', 'japanese', 'katakana', 'Cafe vocabulary', 'Say the katakana word for ''juice'': ジュース', 'spoken response', $json$[]$json$::jsonb, 'juusu', 'This checks comfort with long vowel timing inside a common cafe word.', 8)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-special-1', 'japanese', 'special-kana', 'Yoon combination', 'How do you read きゃ?', 'short answer', $json$[]$json$::jsonb, 'kya', 'The small ゃ combines with the previous kana into one blended syllable.', 9)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-special-2', 'japanese', 'special-kana', 'Small tsu timing', 'What does the small っ usually signal in speech?', 'short answer', $json$[]$json$::jsonb, 'A brief pause or doubled consonant.', 'The learner should feel a short stop before the next consonant rather than adding an extra vowel.', 10)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-special-3', 'japanese', 'special-kana', 'Voiced contrast', 'Which sound pair shows an unvoiced to voiced shift?', 'multiple choice', $json$["ha -> pa","ka -> ga","ya -> wa"]$json$::jsonb, 'ka -> ga', 'Dakuon adds voicing, so the learner hears the sound become heavier at the start.', 11)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-numbers-1', 'japanese', 'numbers', 'Practical counting', 'Say 47 in Japanese.', 'spoken response', $json$[]$json$::jsonb, 'yon juu nana', 'This checks the learner''s ability to combine tens and units clearly in live speech.', 12)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-numbers-2', 'japanese', 'numbers', 'Time telling', 'How do you say 7 o''clock?', 'short answer', $json$[]$json$::jsonb, 'shichi ji', 'Hour expressions are core N5 survival Japanese and should come out quickly without translation delay.', 13)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-numbers-3', 'japanese', 'numbers', 'Money use', 'How would you answer ''How much is it?'' if the price is 500 yen?', 'spoken response', $json$[]$json$::jsonb, 'go hyaku en desu', 'Practical money answers should come out as one smooth phrase, not as isolated number words.', 14)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-vocab-1', 'japanese', 'vocabulary', 'Daily greeting use', 'What do you say to someone in the morning?', 'short answer', $json$[]$json$::jsonb, 'ohayou gozaimasu', 'This is one of the highest-frequency polite expressions in beginner Japanese.', 15)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-vocab-2', 'japanese', 'vocabulary', 'Everyday object recall', 'Which word means ''water''?', 'multiple choice', $json$["ほん","みず","えき"]$json$::jsonb, 'みず', 'Core everyday nouns should become fast retrieval items in N5 speaking.', 16)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-vocab-3', 'japanese', 'vocabulary', 'Self-introduction language', 'Say the Japanese word for ''student''.', 'spoken response', $json$[]$json$::jsonb, 'gakusei', 'This word appears constantly in first conversations and classroom-style roleplay.', 17)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-particle-1', 'japanese', 'particles', 'Topic marking', 'Choose the correct particle: わたし ___ ラフルです。', 'multiple choice', $json$["を","は","で"]$json$::jsonb, 'は', 'は marks the topic of the sentence in this basic self-introduction pattern.', 18)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-particle-2', 'japanese', 'particles', 'Object marking', 'Complete the line: パン ___ たべます。', 'short answer', $json$[]$json$::jsonb, 'を', 'を marks the direct object, so it links the food being eaten to the verb.', 19)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-particle-3', 'japanese', 'particles', 'Place of action', 'Which particle fits: がっこう ___ べんきょうします。', 'multiple choice', $json$["に","で","と"]$json$::jsonb, 'で', 'で marks the place where an action happens.', 20)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-verbs-1', 'japanese', 'verbs-adjectives', 'Polite negative', 'Change たべます into the polite negative form.', 'short answer', $json$[]$json$::jsonb, 'たべません', 'The learner should be able to move from polite affirmative into polite negative quickly.', 21)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-verbs-2', 'japanese', 'verbs-adjectives', 'Past tense', 'What is the past polite form of いきます?', 'short answer', $json$[]$json$::jsonb, 'いきました', 'This is a core N5 conjugation used constantly in past-experience sentences.', 22)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-verbs-3', 'japanese', 'verbs-adjectives', 'Adjective distinction', 'Which one is a な-adjective?', 'multiple choice', $json$["おおきい","しずか","あたらしい"]$json$::jsonb, 'しずか', 'しずか is a classic beginner な-adjective, unlike い-adjectives such as おおきい.', 23)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-grammar-1', 'japanese', 'grammar', 'Permission pattern', 'How do you say ''May I sit here?'' using てもいいですか?', 'spoken response', $json$[]$json$::jsonb, 'ここに すわっても いいですか', 'The learner should connect the te-form to a practical permission request.', 24)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-grammar-2', 'japanese', 'grammar', 'Request pattern', 'Fill in the pattern: もういちど いって ___。', 'short answer', $json$[]$json$::jsonb, 'ください', 'てください is one of the most useful N5 request forms and should feel automatic.', 25)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-grammar-3', 'japanese', 'grammar', 'Desire expression', 'Choose the best completion: みずが ___ です。', 'multiple choice', $json$["たべたい","ほしい","じょうず"]$json$::jsonb, 'ほしい', 'ほしい expresses wanting a thing, which makes it different from たい for wanting to do an action.', 26)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-counters-1', 'japanese', 'counters', 'People counting', 'How do you say ''two people''?', 'short answer', $json$[]$json$::jsonb, 'ふたり', 'This is an irregular but extremely common counter form and should be memorized early.', 27)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-counters-2', 'japanese', 'counters', 'General item counting', 'Count three small objects using the general counter.', 'spoken response', $json$[]$json$::jsonb, 'みっつ', 'The learner should know the native-style item counters for common small quantities.', 28)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-counters-3', 'japanese', 'counters', 'Age expression', 'How would you say ''I am 20 years old''?', 'spoken response', $json$[]$json$::jsonb, 'はたちです', 'Age is a classic N5 speaking topic, and twenty has a special form worth practicing.', 29)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-kanji-1', 'japanese', 'kanji', 'Basic kanji reading', 'Read this word aloud: 日本', 'spoken response', $json$[]$json$::jsonb, 'にほん', 'This checks whether the learner can read one of the most common N5 kanji compounds naturally.', 30)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-kanji-2', 'japanese', 'kanji', 'Meaning recognition', 'Which kanji means ''person''?', 'multiple choice', $json$["日","人","月"]$json$::jsonb, '人', '人 appears across family, counting, jobs, and identity expressions throughout N5 content.', 31)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-kanji-3', 'japanese', 'kanji', 'Useful place word', 'What is the reading of 学校?', 'short answer', $json$[]$json$::jsonb, 'がっこう', 'This is one of the most useful N5 location words and combines a small pause sound with kanji recognition.', 32)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-listening-1', 'japanese', 'listening', 'Number listening', 'You hear さんびゃくえん. What did the speaker say?', 'short answer', $json$[]$json$::jsonb, '300 yen', 'The learner should connect heard Japanese number language to a practical shopping meaning quickly.', 33)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-listening-2', 'japanese', 'listening', 'Greeting recognition', 'If the tutor says こんばんは, what situation is most likely?', 'multiple choice', $json$["A morning greeting","An evening greeting","A farewell at school"]$json$::jsonb, 'An evening greeting', 'Listening tasks should train context recognition, not only literal translation.', 34)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-listening-3', 'japanese', 'listening', 'Question response', 'You hear おなまえは？ What is the speaker asking?', 'short answer', $json$[]$json$::jsonb, 'What is your name?', 'The learner should react to core conversation questions immediately during live speaking.', 35)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-reading-1', 'japanese', 'reading', 'Short sentence reading', 'Read and understand: わたしは えきへ いきます。', 'short answer', $json$[]$json$::jsonb, 'I am going to the station.', 'The sentence combines topic marking, destination marking, and a high-frequency place noun.', 36)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-reading-2', 'japanese', 'reading', 'Tiny paragraph meaning', 'A card says: きょうは にちようびです。 What key information should you understand?', 'short answer', $json$[]$json$::jsonb, 'Today is Sunday.', 'This is exactly the level of calm, useful comprehension we want from beginner reading work.', 37)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-reading-3', 'japanese', 'reading', 'Mixed-script recognition', 'Which reading matches スーパー?', 'multiple choice', $json$["suupaa","shuupaa","sopaa"]$json$::jsonb, 'suupaa', 'Katakana reading confidence is necessary because everyday Japanese signage uses borrowed words constantly.', 38)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-speaking-1', 'japanese', 'speaking', 'Self introduction', 'Give a short introduction with your name and nationality.', 'guided response', $json$[]$json$::jsonb, 'わたしは ___ です。___ から きました。', 'This is one of the best integrated N5 speaking tasks because it combines identity, grammar, and clear pacing.', 39)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-speaking-2', 'japanese', 'speaking', 'Ordering food', 'Say: ''One coffee, please.''', 'spoken response', $json$[]$json$::jsonb, 'コーヒーを ひとつ ください', 'The learner should combine the object marker, counter, and request pattern in one polite cafe line.', 40)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;

insert into public.curriculum_exam_questions (id, language_slug, section_id, skill_focus, prompt, question_type, choices, correct_answer, explanation, sort_order)
values
  ('n5-speaking-3', 'japanese', 'speaking', 'Asking for direction help', 'How would you ask ''Where is the station?''', 'spoken response', $json$[]$json$::jsonb, 'えきは どこですか', 'This is a compact, high-value survival question for travel and daily speaking confidence.', 41)
on conflict (id) do update set
  skill_focus = excluded.skill_focus,
  prompt = excluded.prompt,
  question_type = excluded.question_type,
  choices = excluded.choices,
  correct_answer = excluded.correct_answer,
  explanation = excluded.explanation,
  sort_order = excluded.sort_order;