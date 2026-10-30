-- Seed Episode 001: Ordering Coffee (5 speaking flashcards)

insert into public.episodes (
  id,
  title,
  topic,
  description,
  language,
  status,
  published_at
)
values (
  'db70b939405121f61a0f82b6',
  'Ordering Coffee',
  'Daily Conversations · Café & Food',
  'Practice polite everyday café requests, customizing drinks, and handling barista follow-up questions naturally.',
  'en-US',
  'published',
  now()
)
on conflict (id) do update
  set title = excluded.title,
      topic = excluded.topic,
      description = excluded.description,
      language = excluded.language,
      status = excluded.status,
      published_at = coalesce(public.episodes.published_at, excluded.published_at);

insert into public.cards (
  id,
  episode_id,
  sort_order,
  level,
  context,
  question,
  task,
  answer,
  audio_url,
  content_version
)
values
  (
    'episode-001-a2-order',
    'db70b939405121f61a0f82b6',
    1,
    'A2',
    'At the café counter',
    'Hi there! What can I get started for you?',
    'Order a medium iced latte politely.',
    'Could I get a medium iced latte, please?',
    null,
    1
  ),
  (
    'episode-001-a2-milk',
    'db70b939405121f61a0f82b6',
    2,
    'A2',
    'Customizing your drink',
    'Sure thing. Whole milk okay, or would you like an alternative?',
    'Ask for oat milk instead.',
    'Could you make it with oat milk instead, please?',
    null,
    1
  ),
  (
    'episode-001-b1-sweetness',
    'db70b939405121f61a0f82b6',
    3,
    'B1',
    'Adjusting flavor & ice',
    'Got it, oat milk iced latte. Anything else with that?',
    'Ask for less ice and half the usual sweetness.',
    'Could I also do light ice and just half-sweet, please?',
    null,
    1
  ),
  (
    'episode-001-b1-pastry',
    'db70b939405121f61a0f82b6',
    4,
    'B1',
    'Adding a snack',
    'No problem! Would you like anything to eat today?',
    'Add an almond croissant and ask for it warmed up.',
    'Yes, I''ll take an almond croissant too—could you warm it up for me?',
    null,
    1
  ),
  (
    'episode-001-b2-for-here',
    'db70b939405121f61a0f82b6',
    5,
    'B2',
    'Wrapping up & paying',
    'Will that be for here or to go, and how would you like to pay?',
    'Say you are staying in and ask to pay by tapping your card.',
    'For here, please—and I''ll pay by card if I can just tap.',
    null,
    1
  )
on conflict (id) do update
  set episode_id = excluded.episode_id,
      sort_order = excluded.sort_order,
      level = excluded.level,
      context = excluded.context,
      question = excluded.question,
      task = excluded.task,
      answer = excluded.answer,
      audio_url = excluded.audio_url,
      content_version = excluded.content_version;
