create index if not exists user_module_progress_user_language_module_idx
  on public.user_module_progress (user_id, language_slug, module_id);
