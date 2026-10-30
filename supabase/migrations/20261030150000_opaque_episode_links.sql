-- Import links use an unguessable id. The Ordering Coffee title stays the same.
-- Clients must not be able to list every published episode, or the id is pointless.

insert into public.episodes (
  id,
  title,
  topic,
  description,
  language,
  source_url,
  status,
  published_at,
  created_at,
  updated_at
)
select
  'db70b939405121f61a0f82b6',
  title,
  topic,
  description,
  language,
  source_url,
  status,
  published_at,
  created_at,
  updated_at
from public.episodes
where id = 'episode-001'
  and not exists (
    select 1 from public.episodes where id = 'db70b939405121f61a0f82b6'
  );

update public.cards
set episode_id = 'db70b939405121f61a0f82b6'
where episode_id = 'episode-001'
  and exists (
    select 1 from public.episodes where id = 'db70b939405121f61a0f82b6'
  );

update public.user_episode_imports
set episode_id = 'db70b939405121f61a0f82b6'
where episode_id = 'episode-001'
  and exists (
    select 1 from public.episodes where id = 'db70b939405121f61a0f82b6'
  );

delete from public.episodes
where id = 'episode-001'
  and exists (
    select 1 from public.episodes where id = 'db70b939405121f61a0f82b6'
  );

revoke select on public.episodes, public.cards from anon;

drop policy if exists "episodes_select_published" on public.episodes;
drop policy if exists "cards_select_published_episode" on public.cards;

create policy "episodes_select_imported"
  on public.episodes
  for select
  to authenticated
  using (
    status = 'published'
    and exists (
      select 1
      from public.user_episode_imports i
      where i.episode_id = episodes.id
        and i.user_id = (select auth.uid())
    )
  );

create policy "cards_select_imported"
  on public.cards
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.user_episode_imports i
      where i.episode_id = cards.episode_id
        and i.user_id = (select auth.uid())
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

alter function public.import_episode_deck(text) security definer;
