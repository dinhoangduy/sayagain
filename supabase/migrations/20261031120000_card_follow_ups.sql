-- Cards can carry up to three follow-up questions, each linking to another deck by code.

alter table public.cards
  add column if not exists follow_ups jsonb;

alter table public.cards
  drop constraint if exists cards_follow_ups_chk;

alter table public.cards
  add constraint cards_follow_ups_chk
  check (
    follow_ups is null
    or (
      jsonb_typeof(follow_ups) = 'array'
      and jsonb_array_length(follow_ups) <= 3
    )
  );

create or replace function public.get_published_deck(p_episode_id text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when e.id is null then null
    else jsonb_build_object(
      'episode', jsonb_build_object(
        'id', e.id,
        'title', e.title,
        'topic', e.topic,
        'description', e.description,
        'language', e.language,
        'source_url', e.source_url,
        'status', e.status
      ),
      'cards', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', c.id,
            'level', c.level,
            'context', c.context,
            'question', c.question,
            'task', c.task,
            'answer', c.answer,
            'image_url', c.image_url,
            'framework', c.framework,
            'follow_ups', c.follow_ups,
            'sort_order', c.sort_order
          )
          order by c.sort_order
        )
        from public.cards c
        where c.episode_id = e.id
      ), '[]'::jsonb)
    )
  end
  from (select 1) as seed
  left join public.episodes e
    on e.id = btrim(coalesce(p_episode_id, ''))
   and e.status = 'published';
$$;

revoke all on function public.get_published_deck(text) from public;
grant execute on function public.get_published_deck(text) to anon, authenticated;

create or replace function public.sync_study_collection(p_reviews jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_review jsonb;
  v_result jsonb;
  v_uploaded jsonb := '[]'::jsonb;
  v_items jsonb;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  if jsonb_typeof(coalesce(p_reviews, '[]'::jsonb)) <> 'array' then
    raise exception 'invalid_reviews' using errcode = '22023';
  end if;

  if jsonb_array_length(coalesce(p_reviews, '[]'::jsonb)) > 300 then
    raise exception 'too_many_reviews' using errcode = '22023';
  end if;

  for v_review in
    select value
    from jsonb_array_elements(coalesce(p_reviews, '[]'::jsonb))
  loop
    begin
      v_result := public.submit_card_review(
        (v_review->>'p_event_id')::uuid,
        v_review->>'p_card_id',
        (v_review->>'p_expected_version')::integer,
        (v_review->>'p_rating')::smallint,
        (v_review->>'p_fsrs_state')::smallint,
        (v_review->>'p_due_offset_ms')::bigint,
        (v_review->>'p_stability')::double precision,
        (v_review->>'p_difficulty')::double precision,
        (v_review->>'p_elapsed_days')::integer,
        (v_review->>'p_scheduled_days')::integer,
        (v_review->>'p_learning_steps')::integer,
        (v_review->>'p_reps')::integer,
        (v_review->>'p_lapses')::integer
      );
      v_uploaded := v_uploaded || jsonb_build_array(
        jsonb_build_object(
          'eventId', v_review->>'p_event_id',
          'status', v_result->>'status'
        )
      );
    exception
      when others then
        v_uploaded := v_uploaded || jsonb_build_array(
          jsonb_build_object(
            'eventId', v_review->>'p_event_id',
            'status', 'error'
          )
        );
    end;
  end loop;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'userCard', jsonb_build_object(
          'id', uc.id,
          'user_id', uc.user_id,
          'card_id', uc.card_id,
          'due_at', uc.due_at,
          'last_review_at', uc.last_review_at,
          'fsrs_state', uc.fsrs_state,
          'stability', uc.stability,
          'difficulty', uc.difficulty,
          'elapsed_days', uc.elapsed_days,
          'scheduled_days', uc.scheduled_days,
          'learning_steps', uc.learning_steps,
          'reps', uc.reps,
          'lapses', uc.lapses,
          'version', uc.version,
          'created_at', uc.created_at,
          'updated_at', uc.updated_at
        ),
        'card', jsonb_build_object(
          'id', c.id,
          'episode_id', c.episode_id,
          'level', c.level,
          'context', c.context,
          'question', c.question,
          'task', c.task,
          'answer', c.answer,
          'audio_url', c.audio_url,
          'image_url', c.image_url,
          'framework', c.framework,
          'follow_ups', c.follow_ups
        ),
        'episode', jsonb_build_object(
          'id', e.id,
          'title', e.title,
          'topic', e.topic,
          'language', e.language
        )
      )
      order by uc.due_at asc, c.sort_order asc
    ),
    '[]'::jsonb
  )
    into v_items
  from public.user_cards uc
  join public.cards c on c.id = uc.card_id
  join public.episodes e on e.id = c.episode_id
  where uc.user_id = v_user_id
    and e.status = 'published';

  return jsonb_build_object(
    'uploaded', v_uploaded,
    'items', v_items,
    'server_time', now()
  );
end;
$$;

revoke all on function public.sync_study_collection(jsonb) from public;
grant execute on function public.sync_study_collection(jsonb) to authenticated;
