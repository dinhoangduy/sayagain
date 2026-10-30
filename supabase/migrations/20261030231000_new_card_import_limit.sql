-- Catalog rows include a card count so the device can tell whether a deck fits.
-- Import refuses to insert when the learner would hold more than 5 ungraded cards.

create or replace function public.list_published_catalog()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'id', t.id,
          'title', t.title,
          'topic', t.topic,
          'language', t.language,
          'published_at', t.published_at,
          'card_count', t.card_count
        )
        order by t.published_at desc nulls last, t.id
      )
      from (
        select
          e.id,
          e.title,
          e.topic,
          e.language,
          e.published_at,
          (
            select count(*)::integer
            from public.cards c
            where c.episode_id = e.id
          ) as card_count
        from public.episodes e
        where e.status = 'published'
      ) t
    ),
    '[]'::jsonb
  );
$$;

revoke all on function public.list_published_catalog() from public;
grant execute on function public.list_published_catalog() to anon, authenticated;

create or replace function public.import_episode_deck(p_episode_id text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_episode_id text;
  v_total_cards integer := 0;
  v_added_count integer := 0;
  v_new_count integer := 0;
  v_to_add integer := 0;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user_id::text, 0));

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

  select count(*)::integer
    into v_new_count
    from public.user_cards uc
   where uc.user_id = v_user_id
     and uc.fsrs_state = 0;

  select count(*)::integer
    into v_to_add
    from public.cards c
   where c.episode_id = v_episode_id
     and not exists (
       select 1
       from public.user_cards uc
       where uc.user_id = v_user_id
         and uc.card_id = c.id
     );

  if v_to_add > 0 and v_new_count + v_to_add > 5 then
    raise exception 'new_card_limit' using errcode = 'P0001';
  end if;

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

revoke all on function public.import_episode_deck(text) from public;
grant execute on function public.import_episode_deck(text) to authenticated;
