-- Metadata-only catalog for the import screen.
-- Cards stay behind get_published_deck. Clients cache this payload for a day.

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
