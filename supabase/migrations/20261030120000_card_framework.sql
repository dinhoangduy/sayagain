-- Framework cards: situation or picture on the front, three labeled answers on reveal.
-- Legacy prompt/task/answer cards keep working when framework is null.

alter table public.cards
  add column if not exists image_url text,
  add column if not exists framework jsonb;

alter table public.cards
  alter column level drop not null;

alter table public.cards
  drop constraint if exists cards_level_chk;

alter table public.cards
  add constraint cards_level_chk
  check (level is null or level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

alter table public.cards
  drop constraint if exists cards_framework_chk;

alter table public.cards
  add constraint cards_framework_chk
  check (
    framework is null
    or (
      jsonb_typeof(framework) = 'object'
      and jsonb_typeof(framework -> 'id') = 'string'
      and jsonb_typeof(framework -> 'name') = 'string'
      and jsonb_typeof(framework -> 'steps') = 'array'
      and jsonb_array_length(framework -> 'steps') = 3
    )
  );

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'card-images',
  'card-images',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "card_images_public_read" on storage.objects;

create policy "card_images_public_read"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'card-images');
