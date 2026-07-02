create table if not exists public.api_rate_limits (
  key text primary key,
  count integer not null check (count >= 0),
  reset_at timestamptz not null,
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists api_rate_limits_reset_at_idx
  on public.api_rate_limits (reset_at);

create or replace function public.enforce_api_rate_limit(
  p_key text,
  p_limit integer,
  p_window_ms integer
)
returns table (
  limit_value integer,
  remaining_value integer,
  reset_at timestamptz,
  success boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_state public.api_rate_limits%rowtype;
  now_utc timestamptz := timezone('utc', now());
  next_reset_at timestamptz := timezone('utc', now()) + ((p_window_ms::text || ' milliseconds')::interval);
begin
  loop
    update public.api_rate_limits
    set
      count = case
        when api_rate_limits.reset_at <= now_utc then 1
        else api_rate_limits.count + 1
      end,
      reset_at = case
        when api_rate_limits.reset_at <= now_utc then next_reset_at
        else api_rate_limits.reset_at
      end,
      updated_at = now_utc
    where api_rate_limits.key = p_key
    returning * into current_state;

    if found then
      exit;
    end if;

    begin
      insert into public.api_rate_limits (key, count, reset_at, updated_at)
      values (p_key, 1, next_reset_at, now_utc)
      returning * into current_state;
      exit;
    exception
      when unique_violation then
        null;
    end;
  end loop;

  limit_value := p_limit;
  remaining_value := greatest(0, p_limit - current_state.count);
  reset_at := current_state.reset_at;
  success := current_state.count <= p_limit;
  return next;
end;
$$;
