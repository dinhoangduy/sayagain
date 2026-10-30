-- SayAgain MVP schema, RLS policies, and atomic RPCs
-- Target: Supabase Postgres 17+

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- 1. Episodes
create table if not exists public.episodes (
  id text primary key,
  title text not null,
  topic text not null default '',
  description text not null default '',
  language text not null default 'en-US',
  source_url text,
  status text not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint episodes_id_format_chk check (id ~ '^[a-z0-9][a-z0-9-]{1,63}$'),
  constraint episodes_status_chk check (status in ('draft', 'published', 'archived')),
  constraint episodes_title_nonempty_chk check (char_length(btrim(title)) > 0)
);

create index if not exists episodes_status_published_at_idx
  on public.episodes (status, published_at desc);

create trigger episodes_set_updated_at
  before update on public.episodes
  for each row execute function public.set_updated_at();

-- 2. Cards
create table if not exists public.cards (
  id text primary key,
  episode_id text not null references public.episodes(id) on delete cascade,
  sort_order integer not null default 0,
  level text not null,
  context text not null,
  question text not null,
  task text not null,
  answer text not null,
  audio_url text,
  content_version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cards_id_format_chk check (id ~ '^[a-z0-9][a-z0-9-]{1,95}$'),
  constraint cards_level_chk check (level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  constraint cards_content_version_chk check (content_version >= 1)
);

create index if not exists cards_episode_id_sort_idx
  on public.cards (episode_id, sort_order);

create trigger cards_set_updated_at
  before update on public.cards
  for each row execute function public.set_updated_at();

-- 3. User Cards (per-user FSRS scheduling state + optimistic locking version)
create table if not exists public.user_cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  card_id text not null references public.cards(id) on delete cascade,
  due_at timestamptz not null default now(),
  last_review_at timestamptz,
  fsrs_state smallint not null default 0,
  stability double precision not null default 0,
  difficulty double precision not null default 0,
  elapsed_days integer not null default 0,
  scheduled_days integer not null default 0,
  learning_steps integer not null default 0,
  reps integer not null default 0,
  lapses integer not null default 0,
  version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_cards_user_card_unique unique (user_id, card_id),
  constraint user_cards_fsrs_state_chk check (fsrs_state in (0, 1, 2, 3)),
  constraint user_cards_version_chk check (version >= 1),
  constraint user_cards_nonnegative_chk check (
    stability >= 0
    and difficulty >= 0
    and elapsed_days >= 0
    and scheduled_days >= 0
    and learning_steps >= 0
    and reps >= 0
    and lapses >= 0
  )
);

create index if not exists user_cards_user_due_idx
  on public.user_cards (user_id, due_at);

create index if not exists user_cards_card_id_idx
  on public.user_cards (card_id);

create trigger user_cards_set_updated_at
  before update on public.user_cards
  for each row execute function public.set_updated_at();

-- 4. Review Events (idempotent review history)
create table if not exists public.review_events (
  event_id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  card_id text not null references public.cards(id) on delete cascade,
  rating smallint not null,
  reviewed_at timestamptz not null default now(),
  prior_state jsonb not null,
  resulting_state jsonb not null,
  created_at timestamptz not null default now(),
  constraint review_events_rating_chk check (rating in (1, 2, 3, 4))
);

create index if not exists review_events_user_reviewed_idx
  on public.review_events (user_id, reviewed_at desc);

create index if not exists review_events_card_id_idx
  on public.review_events (card_id);

-- 5. User Episode Imports
create table if not exists public.user_episode_imports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  episode_id text not null references public.episodes(id) on delete cascade,
  imported_at timestamptz not null default now(),
  last_imported_at timestamptz not null default now(),
  constraint user_episode_imports_user_episode_unique unique (user_id, episode_id)
);

create index if not exists user_episode_imports_episode_id_idx
  on public.user_episode_imports (episode_id);

-- 6. User Settings
create table if not exists public.user_settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  timezone text not null default 'UTC',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_settings_timezone_chk check (char_length(btrim(timezone)) between 1 and 100)
);

create trigger user_settings_set_updated_at
  before update on public.user_settings
  for each row execute function public.set_updated_at();

-- Enable Row Level Security on all tables
alter table public.episodes enable row level security;
alter table public.cards enable row level security;
alter table public.user_cards enable row level security;
alter table public.review_events enable row level security;
alter table public.user_episode_imports enable row level security;
alter table public.user_settings enable row level security;

-- Explicit table grants
grant select on public.episodes, public.cards to anon, authenticated;
grant select, insert, update, delete on public.user_cards to authenticated;
grant select, insert, delete on public.review_events to authenticated;
grant select, insert, update, delete on public.user_episode_imports to authenticated;
grant select, insert, update, delete on public.user_settings to authenticated;

-- RLS Policies
create policy "episodes_select_published"
  on public.episodes
  for select
  to anon, authenticated
  using (status = 'published');

create policy "cards_select_published_episode"
  on public.cards
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.episodes e
      where e.id = cards.episode_id
        and e.status = 'published'
    )
  );

create policy "user_cards_select_own"
  on public.user_cards
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "user_cards_insert_own"
  on public.user_cards
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "user_cards_update_own"
  on public.user_cards
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "user_cards_delete_own"
  on public.user_cards
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "review_events_select_own"
  on public.review_events
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "review_events_insert_own"
  on public.review_events
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "review_events_delete_own"
  on public.review_events
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "user_episode_imports_select_own"
  on public.user_episode_imports
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "user_episode_imports_insert_own"
  on public.user_episode_imports
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "user_episode_imports_update_own"
  on public.user_episode_imports
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "user_episode_imports_delete_own"
  on public.user_episode_imports
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "user_settings_select_own"
  on public.user_settings
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "user_settings_insert_own"
  on public.user_settings
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "user_settings_update_own"
  on public.user_settings
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "user_settings_delete_own"
  on public.user_settings
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- Atomic RPC 1: Idempotent episode import (never resets existing FSRS state)
create or replace function public.import_episode_deck(p_episode_id text)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_episode_id text;
  v_total_cards integer := 0;
  v_added_count integer := 0;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  select e.id
    into v_episode_id
    from public.episodes e
   where e.id = btrim(coalesce(p_episode_id, ''))
     and e.status = 'published';

  if v_episode_id is null then
    raise exception 'episode_not_found' using errcode = 'P0002';
  end if;

  select count(*)::integer
    into v_total_cards
    from public.cards c
   where c.episode_id = v_episode_id;

  with inserted as (
    insert into public.user_cards (
      user_id,
      card_id,
      due_at,
      fsrs_state,
      stability,
      difficulty,
      elapsed_days,
      scheduled_days,
      learning_steps,
      reps,
      lapses,
      version
    )
    select
      v_user_id,
      c.id,
      now(),
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1
    from public.cards c
    where c.episode_id = v_episode_id
    order by c.sort_order asc, c.id asc
    on conflict (user_id, card_id) do nothing
    returning card_id
  )
  select count(*)::integer into v_added_count from inserted;

  insert into public.user_episode_imports (
    user_id,
    episode_id,
    imported_at,
    last_imported_at
  )
  values (
    v_user_id,
    v_episode_id,
    now(),
    now()
  )
  on conflict (user_id, episode_id)
  do update set last_imported_at = now();

  return jsonb_build_object(
    'episode_id', v_episode_id,
    'total_cards', v_total_cards,
    'added_count', v_added_count,
    'existing_count', greatest(0, v_total_cards - v_added_count)
  );
end;
$$;

grant execute on function public.import_episode_deck(text) to authenticated;

-- Atomic RPC 2: Transactional, idempotent, version-checked card review persistence
create or replace function public.submit_card_review(
  p_event_id uuid,
  p_card_id text,
  p_expected_version integer,
  p_rating smallint,
  p_fsrs_state smallint,
  p_due_offset_ms bigint,
  p_stability double precision,
  p_difficulty double precision,
  p_elapsed_days integer,
  p_scheduled_days integer,
  p_learning_steps integer,
  p_reps integer,
  p_lapses integer
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_now timestamptz := now();
  v_due_at timestamptz;
  v_current public.user_cards%rowtype;
  v_updated public.user_cards%rowtype;
  v_prior_state jsonb;
  v_resulting_state jsonb;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  if p_event_id is null then
    raise exception 'invalid_event_id' using errcode = '22023';
  end if;

  if p_rating not in (1, 2, 3, 4) then
    raise exception 'invalid_rating' using errcode = '22023';
  end if;

  if p_fsrs_state not in (0, 1, 2, 3) then
    raise exception 'invalid_fsrs_state' using errcode = '22023';
  end if;

  if p_stability < 0 or p_difficulty < 0 or p_elapsed_days < 0
     or p_scheduled_days < 0 or p_learning_steps < 0
     or p_reps < 0 or p_lapses < 0 then
    raise exception 'invalid_fsrs_metrics' using errcode = '22023';
  end if;

  if exists (
    select 1
    from public.review_events re
    where re.event_id = p_event_id
      and re.user_id = v_user_id
  ) then
    select *
      into v_current
      from public.user_cards uc
     where uc.user_id = v_user_id
       and uc.card_id = p_card_id;

    return jsonb_build_object(
      'status', 'already_applied',
      'server_time', v_now,
      'user_card', to_jsonb(v_current)
    );
  end if;

  select *
    into v_current
    from public.user_cards uc
   where uc.user_id = v_user_id
     and uc.card_id = p_card_id
   for update;

  if not found then
    raise exception 'user_card_not_found' using errcode = 'P0002';
  end if;

  if v_current.version <> p_expected_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'server_time', v_now,
      'current_version', v_current.version,
      'user_card', to_jsonb(v_current)
    );
  end if;

  v_due_at := v_now + (
    least(greatest(coalesce(p_due_offset_ms, 0), 0), 3153600000000)::double precision
    * interval '1 millisecond'
  );

  v_prior_state := jsonb_build_object(
    'due_at', v_current.due_at,
    'last_review_at', v_current.last_review_at,
    'fsrs_state', v_current.fsrs_state,
    'stability', v_current.stability,
    'difficulty', v_current.difficulty,
    'elapsed_days', v_current.elapsed_days,
    'scheduled_days', v_current.scheduled_days,
    'learning_steps', v_current.learning_steps,
    'reps', v_current.reps,
    'lapses', v_current.lapses,
    'version', v_current.version
  );

  update public.user_cards
     set due_at = v_due_at,
         last_review_at = v_now,
         fsrs_state = p_fsrs_state,
         stability = p_stability,
         difficulty = p_difficulty,
         elapsed_days = p_elapsed_days,
         scheduled_days = p_scheduled_days,
         learning_steps = p_learning_steps,
         reps = p_reps,
         lapses = p_lapses,
         version = v_current.version + 1,
         updated_at = v_now
   where id = v_current.id
   returning * into v_updated;

  v_resulting_state := jsonb_build_object(
    'due_at', v_updated.due_at,
    'last_review_at', v_updated.last_review_at,
    'fsrs_state', v_updated.fsrs_state,
    'stability', v_updated.stability,
    'difficulty', v_updated.difficulty,
    'elapsed_days', v_updated.elapsed_days,
    'scheduled_days', v_updated.scheduled_days,
    'learning_steps', v_updated.learning_steps,
    'reps', v_updated.reps,
    'lapses', v_updated.lapses,
    'version', v_updated.version
  );

  insert into public.review_events (
    event_id,
    user_id,
    card_id,
    rating,
    reviewed_at,
    prior_state,
    resulting_state
  )
  values (
    p_event_id,
    v_user_id,
    p_card_id,
    p_rating,
    v_now,
    v_prior_state,
    v_resulting_state
  );

  return jsonb_build_object(
    'status', 'ok',
    'server_time', v_now,
    'user_card', to_jsonb(v_updated)
  );
end;
$$;

grant execute on function public.submit_card_review(
  uuid, text, integer, smallint, smallint, bigint,
  double precision, double precision, integer, integer, integer, integer, integer
) to authenticated;
