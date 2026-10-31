-- Import 66 conversation-survival decks, then 50 scenario decks.
-- Scenario follow-ups point at survival decks by code inside cards.follow_ups.
-- Safe to run again: the same code updates the existing episode and card.
--
-- The original id checks only allow lowercase. SCN-001 and CSF-001 need letters of either case.

alter table public.episodes drop constraint if exists episodes_id_format_chk;
alter table public.episodes add constraint episodes_id_format_chk
  check (id ~ '^[A-Za-z0-9][A-Za-z0-9-]{1,63}$');

alter table public.cards drop constraint if exists cards_id_format_chk;
alter table public.cards add constraint cards_id_format_chk
  check (id ~ '^[A-Za-z0-9][A-Za-z0-9-]{1,95}$');

begin;


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-001', 'You missed the last part in a noisy cafe', 'Asking for Clarification', 'You''re arranging a handover with a coworker in a crowded cafe, and you miss the last part of their request.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-001',
  'CSF-001',
  1,
  null,
  'You''re arranging a handover with a coworker in a crowded cafe, and you miss the last part of their request.',
  'Can you send the revised files to Maya after lunch?',
  'Repair → Context → Request',
  'Sorry, I didn''t quite catch that. It''s pretty noisy in here. Could you say the last part again?',
  '{"id":"repair-context-request","name":"Repair → Context → Request","steps":[{"label":"Repair","answer":"Sorry, I didn''t quite catch that."},{"label":"Context","answer":"It''s pretty noisy in here."},{"label":"Request","answer":"Could you say the last part again?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-002', 'A colleague is speaking too fast', 'Asking for Clarification', 'On a video call, a colleague gives several setup steps so quickly that you can''t follow the second half.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-002',
  'CSF-002',
  1,
  null,
  'On a video call, a colleague gives several setup steps so quickly that you can''t follow the second half.',
  'Does that make sense, or should I move on?',
  'Acknowledge → Request → Reason',
  'I got the first part. Could you say that a little more slowly? I don''t want to miss the next step.',
  '{"id":"acknowledge-request-reason","name":"Acknowledge → Request → Reason","steps":[{"label":"Acknowledge","answer":"I got the first part."},{"label":"Request","answer":"Could you say that a little more slowly?"},{"label":"Reason","answer":"I don''t want to miss the next step."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-003', 'Your manager says to be flexible', 'Asking for Clarification', 'Your manager wants the delivery plan to be ''more flexible,'' but you''re not sure what should change.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-003',
  'CSF-003',
  1,
  null,
  'Your manager wants the delivery plan to be ''more flexible,'' but you''re not sure what should change.',
  'Can you be a bit more flexible with the timeline?',
  'Acknowledge → Clarify → Options',
  'I can adjust the plan. What do you mean by ''flexible'' here? Are we moving the deadline or changing the scope?',
  '{"id":"acknowledge-clarify-options","name":"Acknowledge → Clarify → Options","steps":[{"label":"Acknowledge","answer":"I can adjust the plan."},{"label":"Clarify","answer":"What do you mean by ''flexible'' here?"},{"label":"Options","answer":"Are we moving the deadline or changing the scope?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-004', 'Next Friday could mean two different dates', 'Asking for Clarification', 'A teammate suggests moving a meeting to ''next Friday,'' and you aren''t sure which week they mean.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-004',
  'CSF-004',
  1,
  null,
  'A teammate suggests moving a meeting to ''next Friday,'' and you aren''t sure which week they mean.',
  'Can we move the review to next Friday?',
  'Acknowledge → Clarify → Reason',
  'Sure, that could work. When you say next Friday, do you mean this coming Friday or the one after? I just want to put the right date on my calendar.',
  '{"id":"acknowledge-clarify-reason","name":"Acknowledge → Clarify → Reason","steps":[{"label":"Acknowledge","answer":"Sure, that could work."},{"label":"Clarify","answer":"When you say next Friday, do you mean this coming Friday or the one after?"},{"label":"Reason","answer":"I just want to put the right date on my calendar."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-005', 'A design comment is too vague', 'Asking for Clarification', 'A teammate says the new page should feel ''more intuitive'' but gives no specific example.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-005',
  'CSF-005',
  1,
  null,
  'A teammate says the new page should feel ''more intuitive'' but gives no specific example.',
  'Can we make this page feel more intuitive?',
  'Acknowledge → Request → Reason',
  'I see what you''re getting at. Could you give me an example? It''d help me understand which part feels confusing.',
  '{"id":"acknowledge-request-reason","name":"Acknowledge → Request → Reason","steps":[{"label":"Acknowledge","answer":"I see what you''re getting at."},{"label":"Request","answer":"Could you give me an example?"},{"label":"Reason","answer":"It''d help me understand which part feels confusing."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-006', 'You need to confirm a complex handover', 'Asking for Clarification', 'Your project lead mentioned a draft today and a final file early next week, but you want to confirm whether Monday is the date.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-006',
  'CSF-006',
  1,
  null,
  'Your project lead mentioned a draft today and a final file early next week, but you want to confirm whether Monday is the date.',
  'Are we clear on when each version goes out?',
  'Check → Detail → Confirm',
  'Just to make sure I''ve got this right, we''re sending the draft today. The final version goes out on Monday. Is that the plan?',
  '{"id":"check-detail-confirm","name":"Check → Detail → Confirm","steps":[{"label":"Check","answer":"Just to make sure I''ve got this right, we''re sending the draft today."},{"label":"Detail","answer":"The final version goes out on Monday."},{"label":"Confirm","answer":"Is that the plan?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-007', 'Which files does your teammate mean?', 'Asking for Clarification', 'Your teammate asks you to update ''the older files,'' but your team has both website files and reports.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-007',
  'CSF-007',
  1,
  null,
  'Your teammate asks you to update ''the older files,'' but your team has both website files and reports.',
  'Could you update the older files first?',
  'Willingness → Clarify → Reason',
  'I can get started on that. Did you mean the website files or the reports? I want to make sure I update the right ones.',
  '{"id":"willingness-clarify-reason","name":"Willingness → Clarify → Reason","steps":[{"label":"Willingness","answer":"I can get started on that."},{"label":"Clarify","answer":"Did you mean the website files or the reports?"},{"label":"Reason","answer":"I want to make sure I update the right ones."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-008', 'A place name is hard to spell', 'Asking for Clarification', 'A customer gives you a city name you haven''t heard before for an international delivery.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-008',
  'CSF-008',
  1,
  null,
  'A customer gives you a city name you haven''t heard before for an international delivery.',
  'Please send the package to Szczecin in Poland.',
  'Acknowledge → Request → Reason',
  'Got it, I''ll note the city down. Could you spell that for me? I don''t want the package going to the wrong place.',
  '{"id":"acknowledge-request-reason","name":"Acknowledge → Request → Reason","steps":[{"label":"Acknowledge","answer":"Got it, I''ll note the city down."},{"label":"Request","answer":"Could you spell that for me?"},{"label":"Reason","answer":"I don''t want the package going to the wrong place."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-009', 'An interview question catches you off guard', 'Buying Time', 'An interviewer asks what you would change about a project you worked on, and you need a few seconds to choose an example.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-009',
  'CSF-009',
  1,
  null,
  'An interviewer asks what you would change about a project you worked on, and you need a few seconds to choose an example.',
  'What would you do differently on your last project?',
  'Acknowledge → Pause → Answer',
  'That''s a good question. Let me think for a second. I''d say we should''ve spotted the risks earlier.',
  '{"id":"acknowledge-pause-answer","name":"Acknowledge → Pause → Answer","steps":[{"label":"Acknowledge","answer":"That''s a good question."},{"label":"Pause","answer":"Let me think for a second."},{"label":"Answer","answer":"I''d say we should''ve spotted the risks earlier."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-010', 'You need to check your weekend plans', 'Buying Time', 'A friend invites you on a day trip, but you don''t know whether you''ll need to work.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-010',
  'CSF-010',
  1,
  null,
  'A friend invites you on a day trip, but you don''t know whether you''ll need to work.',
  'Do you want to come with us on Saturday?',
  'Interest → Constraint → Request',
  'I''d love to come. I need to check if I''m working that day. Can I get back to you on that?',
  '{"id":"interest-constraint-request","name":"Interest → Constraint → Request","steps":[{"label":"Interest","answer":"I''d love to come."},{"label":"Constraint","answer":"I need to check if I''m working that day."},{"label":"Request","answer":"Can I get back to you on that?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-011', 'A customer asks about room availability', 'Buying Time', 'You''re covering the hotel front desk and a guest asks whether they can extend their stay.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-011',
  'CSF-011',
  1,
  null,
  'You''re covering the hotel front desk and a guest asks whether they can extend their stay.',
  'Do you have a room available for one more night?',
  'Acknowledge → Pause → Next step',
  'I can look that up for you. Give me a moment to check. I''ll let you know what I find.',
  '{"id":"acknowledge-pause-next-step","name":"Acknowledge → Pause → Next step","steps":[{"label":"Acknowledge","answer":"I can look that up for you."},{"label":"Pause","answer":"Give me a moment to check."},{"label":"Next step","answer":"I''ll let you know what I find."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-012', 'You are recalling a date from memory', 'Buying Time', 'A friend asks when you visited a city last year, and you don''t remember the exact month.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-012',
  'CSF-012',
  1,
  null,
  'A friend asks when you visited a city last year, and you don''t remember the exact month.',
  'When did you go to Seoul again?',
  'Estimate → Uncertainty → Follow-up',
  'Off the top of my head, I think it was in early June. I might be mixing up the dates, though. I''ll check my photos later.',
  '{"id":"estimate-uncertainty-follow-up","name":"Estimate → Uncertainty → Follow-up","steps":[{"label":"Estimate","answer":"Off the top of my head, I think it was in early June."},{"label":"Uncertainty","answer":"I might be mixing up the dates, though."},{"label":"Follow-up","answer":"I''ll check my photos later."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-013', 'A friend asks a difficult personal question', 'Buying Time', 'Over dinner, a friend asks whether you''d move abroad for a better job.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-013',
  'CSF-013',
  1,
  null,
  'Over dinner, a friend asks whether you''d move abroad for a better job.',
  'Would you move overseas if you got a really good job offer?',
  'Reaction → Consideration → Position',
  'That''s a tough one. I''d have to think about my family first. But I wouldn''t rule it out.',
  '{"id":"reaction-consideration-position","name":"Reaction → Consideration → Position","steps":[{"label":"Reaction","answer":"That''s a tough one."},{"label":"Consideration","answer":"I''d have to think about my family first."},{"label":"Position","answer":"But I wouldn''t rule it out."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-014', 'A meeting jumps to numbers too early', 'Buying Time', 'A colleague asks for a spending recommendation before the team has reviewed the budget.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-014',
  'CSF-014',
  1,
  null,
  'A colleague asks for a spending recommendation before the team has reviewed the budget.',
  'So how much should we spend on marketing?',
  'Defer → Reason → Commitment',
  'Can we come back to that after we review the budget? I want to see what we actually have available. Then I can suggest a realistic amount.',
  '{"id":"defer-reason-commitment","name":"Defer → Reason → Commitment","steps":[{"label":"Defer","answer":"Can we come back to that after we review the budget?"},{"label":"Reason","answer":"I want to see what we actually have available."},{"label":"Commitment","answer":"Then I can suggest a realistic amount."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-015', 'You gave the wrong platform number', 'Self-Correction & Reformulation', 'You told a friend to wait at platform three, then noticed the departure board says platform four.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-015',
  'CSF-015',
  1,
  null,
  'You told a friend to wait at platform three, then noticed the departure board says platform four.',
  'You said platform three, right?',
  'Correction → Ownership → Right detail',
  'Sorry, I meant platform four. I mixed up the numbers. The train to Oxford leaves from four.',
  '{"id":"correction-ownership-right-detail","name":"Correction → Ownership → Right detail","steps":[{"label":"Correction","answer":"Sorry, I meant platform four."},{"label":"Ownership","answer":"I mixed up the numbers."},{"label":"Right detail","answer":"The train to Oxford leaves from four."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-016', 'A teammate thinks you want to cancel a launch', 'Self-Correction & Reformulation', 'You''re discussing a possible one-week delay, but a teammate thinks you''re proposing cancellation.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-016',
  'CSF-016',
  1,
  null,
  'You''re discussing a possible one-week delay, but a teammate thinks you''re proposing cancellation.',
  'Are you saying we should cancel the launch?',
  'Clarify → Rephrase → Reason',
  'No, I don''t think we need to cancel it. What I''m trying to say is that we should delay it by a week. That would give us time to fix the bugs.',
  '{"id":"clarify-rephrase-reason","name":"Clarify → Rephrase → Reason","steps":[{"label":"Clarify","answer":"No, I don''t think we need to cancel it."},{"label":"Rephrase","answer":"What I''m trying to say is that we should delay it by a week."},{"label":"Reason","answer":"That would give us time to fix the bugs."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-017', 'A coworker does not see the benefit of a change', 'Self-Correction & Reformulation', 'You''re proposing an extra quality check, and a coworker says it sounds like more work.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-017',
  'CSF-017',
  1,
  null,
  'You''re proposing an extra quality check, and a coworker says it sounds like more work.',
  'I don''t see how an extra check saves us time.',
  'Reframe → Explanation → Benefit',
  'Let me put it another way. We do a little more work upfront, but fewer things break later. That''s where the time savings come from.',
  '{"id":"reframe-explanation-benefit","name":"Reframe → Explanation → Benefit","steps":[{"label":"Reframe","answer":"Let me put it another way."},{"label":"Explanation","answer":"We do a little more work upfront, but fewer things break later."},{"label":"Benefit","answer":"That''s where the time savings come from."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-018', 'A friend takes your comment the wrong way', 'Self-Correction & Reformulation', 'You said a friend''s business idea was ''a bit crazy,'' and they look hurt.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-018',
  'CSF-018',
  1,
  null,
  'You said a friend''s business idea was ''a bit crazy,'' and they look hurt.',
  'Are you saying my idea is stupid?',
  'Own it → Clarify → Reassure',
  'No, that came out wrong. I meant the timing might be difficult, not that your idea is bad. I actually think it''s worth trying.',
  '{"id":"own-it-clarify-reassure","name":"Own it → Clarify → Reassure","steps":[{"label":"Own it","answer":"No, that came out wrong."},{"label":"Clarify","answer":"I meant the timing might be difficult, not that your idea is bad."},{"label":"Reassure","answer":"I actually think it''s worth trying."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-019', 'You overstated your role in an interview', 'Self-Correction & Reformulation', 'In a job interview, you accidentally made it sound like you led an entire product launch.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-019',
  'CSF-019',
  1,
  null,
  'In a job interview, you accidentally made it sound like you led an entire product launch.',
  'So you managed that whole launch yourself?',
  'Correction → Ownership → Contribution',
  'I should''ve said I coordinated the testing, not the whole launch. The project manager handled the overall schedule. I worked closely with her on the release.',
  '{"id":"correction-ownership-contribution","name":"Correction → Ownership → Contribution","steps":[{"label":"Correction","answer":"I should''ve said I coordinated the testing, not the whole launch."},{"label":"Ownership","answer":"The project manager handled the overall schedule."},{"label":"Contribution","answer":"I worked closely with her on the release."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-020', 'A teammate misunderstood your feature idea', 'Self-Correction & Reformulation', 'You suggested limiting a new feature for testing, but your teammate believes you want to remove it for everyone.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-020',
  'CSF-020',
  1,
  null,
  'You suggested limiting a new feature for testing, but your teammate believes you want to remove it for everyone.',
  'So you want us to remove that feature?',
  'Rephrase → Boundary → Reason',
  'What I meant was we could hide it for new users. Existing users would still have access. That would let us test the change safely.',
  '{"id":"rephrase-boundary-reason","name":"Rephrase → Boundary → Reason","steps":[{"label":"Rephrase","answer":"What I meant was we could hide it for new users."},{"label":"Boundary","answer":"Existing users would still have access."},{"label":"Reason","answer":"That would let us test the change safely."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-021', 'You lose your place during a presentation', 'Self-Correction & Reformulation', 'You''re presenting in a meeting and suddenly forget where you were going with your explanation.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-021',
  'CSF-021',
  1,
  null,
  'You''re presenting in a meeting and suddenly forget where you were going with your explanation.',
  'You were talking about the second step?',
  'Recovery → Topic → Continue',
  'Right, I lost my train of thought for a second. I was talking about how we check the data. Then we send it for approval.',
  '{"id":"recovery-topic-continue","name":"Recovery → Topic → Continue","steps":[{"label":"Recovery","answer":"Right, I lost my train of thought for a second."},{"label":"Topic","answer":"I was talking about how we check the data."},{"label":"Continue","answer":"Then we send it for approval."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-022', 'Your coworker asks about your weekend', 'Keeping Conversation Going', 'A coworker starts some friendly small talk before the Monday meeting.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-022',
  'CSF-022',
  1,
  null,
  'A coworker starts some friendly small talk before the Monday meeting.',
  'How was your weekend?',
  'Update → Detail → Ask back',
  'Pretty good, I went hiking with some friends. The weather was perfect for it. How about you?',
  '{"id":"update-detail-ask-back","name":"Update → Detail → Ask back","steps":[{"label":"Update","answer":"Pretty good, I went hiking with some friends."},{"label":"Detail","answer":"The weather was perfect for it."},{"label":"Ask back","answer":"How about you?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-023', 'A friend traveled alone for a month', 'Keeping Conversation Going', 'At dinner, a friend casually mentions taking a long solo trip.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-023',
  'CSF-023',
  1,
  null,
  'At dinner, a friend casually mentions taking a long solo trip.',
  'I spent a month traveling alone last summer.',
  'React → Feeling → Question',
  'A whole month on your own sounds exciting. I''d be nervous traveling alone for that long. What was that like?',
  '{"id":"react-feeling-question","name":"React → Feeling → Question","steps":[{"label":"React","answer":"A whole month on your own sounds exciting."},{"label":"Feeling","answer":"I''d be nervous traveling alone for that long."},{"label":"Question","answer":"What was that like?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-024', 'A coworker mentions starting a business', 'Keeping Conversation Going', 'A coworker tells you they''re thinking about working for themselves next year.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-024',
  'CSF-024',
  1,
  null,
  'A coworker tells you they''re thinking about working for themselves next year.',
  'I might start my own business next year.',
  'React → Interest → Invite',
  'That''s exciting, especially if you''re starting from scratch. I''d love to know what you''re planning. Tell me more about that.',
  '{"id":"react-interest-invite","name":"React → Interest → Invite","steps":[{"label":"React","answer":"That''s exciting, especially if you''re starting from scratch."},{"label":"Interest","answer":"I''d love to know what you''re planning."},{"label":"Invite","answer":"Tell me more about that."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-025', 'A friend asked their boss for a raise', 'Keeping Conversation Going', 'Your friend tells you they finally had a salary conversation they''ve been putting off.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-025',
  'CSF-025',
  1,
  null,
  'Your friend tells you they finally had a salary conversation they''ve been putting off.',
  'I finally asked my boss for a raise.',
  'Support → Emotion → Outcome',
  'Oh, good for you. That must''ve been a nerve-racking conversation. How did that turn out?',
  '{"id":"support-emotion-outcome","name":"Support → Emotion → Outcome","steps":[{"label":"Support","answer":"Oh, good for you."},{"label":"Emotion","answer":"That must''ve been a nerve-racking conversation."},{"label":"Outcome","answer":"How did that turn out?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-026', 'A friend missed a flight', 'Keeping Conversation Going', 'Your friend starts telling you about a stressful travel day but hasn''t finished the story.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-026',
  'CSF-026',
  1,
  null,
  'Your friend starts telling you about a stressful travel day but hasn''t finished the story.',
  'I missed my flight and had to talk to the airline.',
  'Empathy → Concern → Continue',
  'Oh no, that''s stressful. I hope the airline could help. What happened next?',
  '{"id":"empathy-concern-continue","name":"Empathy → Concern → Continue","steps":[{"label":"Empathy","answer":"Oh no, that''s stressful."},{"label":"Concern","answer":"I hope the airline could help."},{"label":"Continue","answer":"What happened next?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-027', 'You remember a detail from an earlier conversation', 'Keeping Conversation Going', 'You run into someone at a work event who previously told you they were learning Spanish.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-027',
  'CSF-027',
  1,
  null,
  'You run into someone at a work event who previously told you they were learning Spanish.',
  'So, what have you been up to lately?',
  'Update → Recall → Ask',
  'Mostly work, nothing too exciting. You mentioned you were learning Spanish. How''s that going?',
  '{"id":"update-recall-ask","name":"Update → Recall → Ask","steps":[{"label":"Update","answer":"Mostly work, nothing too exciting."},{"label":"Recall","answer":"You mentioned you were learning Spanish."},{"label":"Ask","answer":"How''s that going?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-028', 'A friend mentions moving offices', 'Keeping Conversation Going', 'A friend says their company is relocating, reminding you of a similar experience.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-028',
  'CSF-028',
  1,
  null,
  'A friend says their company is relocating, reminding you of a similar experience.',
  'Our office is moving to a new building next month.',
  'Bridge → Detail → Ask back',
  'That reminds me, our team moved last year. The first week was chaos. Have they told you your moving date yet?',
  '{"id":"bridge-detail-ask-back","name":"Bridge → Detail → Ask back","steps":[{"label":"Bridge","answer":"That reminds me, our team moved last year."},{"label":"Detail","answer":"The first week was chaos."},{"label":"Ask back","answer":"Have they told you your moving date yet?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-029', 'The team is about to skip an action item', 'Handling Interruptions', 'Your meeting is moving on, but nobody has confirmed who will send an important file.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-029',
  'CSF-029',
  1,
  null,
  'Your meeting is moving on, but nobody has confirmed who will send an important file.',
  'Okay, let''s move on to the next topic.',
  'Enter → Question → Purpose',
  'Sorry to jump in, but can I clarify one thing? Who''s sending the updated file? I just want to make sure it doesn''t get missed.',
  '{"id":"enter-question-purpose","name":"Enter → Question → Purpose","steps":[{"label":"Enter","answer":"Sorry to jump in, but can I clarify one thing?"},{"label":"Question","answer":"Who''s sending the updated file?"},{"label":"Purpose","answer":"I just want to make sure it doesn''t get missed."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-030', 'A colleague interrupts your explanation', 'Handling Interruptions', 'You''re explaining your proposal when a colleague interrupts before you''ve reached the relevant point.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-030',
  'CSF-030',
  1,
  null,
  'You''re explaining your proposal when a colleague interrupts before you''ve reached the relevant point.',
  'But isn''t that already in the plan?',
  'Acknowledge → Hold turn → Invite',
  'It is, and I''m getting to that part. Can I finish my thought? Then I''d love to hear your take.',
  '{"id":"acknowledge-hold-turn-invite","name":"Acknowledge → Hold turn → Invite","steps":[{"label":"Acknowledge","answer":"It is, and I''m getting to that part."},{"label":"Hold turn","answer":"Can I finish my thought?"},{"label":"Invite","answer":"Then I''d love to hear your take."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-031', 'Two people start speaking at once', 'Handling Interruptions', 'You and another teammate both begin talking during the same pause in a call.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-031',
  'CSF-031',
  1,
  null,
  'You and another teammate both begin talking during the same pause in a call.',
  'Oh, were you going to say something?',
  'Yield → Interest → Return',
  'Oh, go ahead, you first. It sounds like you''ve got something to add. I''ll jump in after you.',
  '{"id":"yield-interest-return","name":"Yield → Interest → Return","steps":[{"label":"Yield","answer":"Oh, go ahead, you first."},{"label":"Interest","answer":"It sounds like you''ve got something to add."},{"label":"Return","answer":"I''ll jump in after you."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-032', 'A video call cuts out mid-sentence', 'Handling Interruptions', 'The audio drops out as your teammate is talking, and then the connection returns.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-032',
  'CSF-032',
  1,
  null,
  'The audio drops out as your teammate is talking, and then the connection returns.',
  'Can you hear me now?',
  'Connection → Check → Reason',
  'Yeah, I can hear you now. Sorry, were you saying something? Your audio cut out for a second.',
  '{"id":"connection-check-reason","name":"Connection → Check → Reason","steps":[{"label":"Connection","answer":"Yeah, I can hear you now."},{"label":"Check","answer":"Sorry, were you saying something?"},{"label":"Reason","answer":"Your audio cut out for a second."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-033', 'A teammate changes topics before you finish', 'Handling Interruptions', 'You are halfway through a short update when a coworker jumps ahead to pricing.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-033',
  'CSF-033',
  1,
  null,
  'You are halfway through a short update when a coworker jumps ahead to pricing.',
  'Can we talk about pricing instead?',
  'Validate → Hold turn → Limit',
  'Sure, pricing''s important too. Let me just finish this point. It''ll only take a few seconds.',
  '{"id":"validate-hold-turn-limit","name":"Validate → Hold turn → Limit","steps":[{"label":"Validate","answer":"Sure, pricing''s important too."},{"label":"Hold turn","answer":"Let me just finish this point."},{"label":"Limit","answer":"It''ll only take a few seconds."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-034', 'You accidentally spoke over a friend', 'Handling Interruptions', 'You got excited during a story and started talking just as your friend was about to respond.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-034',
  'CSF-034',
  1,
  null,
  'You got excited during a story and started talking just as your friend was about to respond.',
  'Oh, were you going to let me finish?',
  'Apology → Ownership → Return',
  'I didn''t mean to cut you off. I got excited and jumped in. What were you about to say?',
  '{"id":"apology-ownership-return","name":"Apology → Ownership → Return","steps":[{"label":"Apology","answer":"I didn''t mean to cut you off."},{"label":"Ownership","answer":"I got excited and jumped in."},{"label":"Return","answer":"What were you about to say?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-035', 'A cafe story reminds you of another place', 'Changing Topics', 'A friend mentions some pastries they liked, and you want to bring up a new cafe nearby.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-035',
  'CSF-035',
  1,
  null,
  'A friend mentions some pastries they liked, and you want to bring up a new cafe nearby.',
  'That place had the best pastries.',
  'Bridge → Detail → Invite',
  'Speaking of food, I tried the new place near the station. The sandwiches were amazing. Have you been there yet?',
  '{"id":"bridge-detail-invite","name":"Bridge → Detail → Invite","steps":[{"label":"Bridge","answer":"Speaking of food, I tried the new place near the station."},{"label":"Detail","answer":"The sandwiches were amazing."},{"label":"Invite","answer":"Have you been there yet?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-036', 'You remember an email during small talk', 'Changing Topics', 'A coworker thanks you for your presentation, and you need to check an unrelated scheduling detail.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-036',
  'CSF-036',
  1,
  null,
  'A coworker thanks you for your presentation, and you need to check an unrelated scheduling detail.',
  'Thanks, the presentation looks good.',
  'Acknowledge → Shift → Purpose',
  'Glad you like it. By the way, did you get my email about tomorrow''s meeting? I want to make sure we''ve got the right time.',
  '{"id":"acknowledge-shift-purpose","name":"Acknowledge → Shift → Purpose","steps":[{"label":"Acknowledge","answer":"Glad you like it."},{"label":"Shift","answer":"By the way, did you get my email about tomorrow''s meeting?"},{"label":"Purpose","answer":"I want to make sure we''ve got the right time."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-037', 'You need the notes before a call ends', 'Changing Topics', 'Your meeting is wrapping up, and you''ve just remembered you need notes from the first ten minutes.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-037',
  'CSF-037',
  1,
  null,
  'Your meeting is wrapping up, and you''ve just remembered you need notes from the first ten minutes.',
  'Anything else before we wrap up?',
  'Remember → Reason → Benefit',
  'Before I forget, could you send me the meeting notes? I missed the first ten minutes. It''d really help me catch up.',
  '{"id":"remember-reason-benefit","name":"Remember → Reason → Benefit","steps":[{"label":"Remember","answer":"Before I forget, could you send me the meeting notes?"},{"label":"Reason","answer":"I missed the first ten minutes."},{"label":"Benefit","answer":"It''d really help me catch up."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-038', 'The schedule leads to a question about testing', 'Changing Topics', 'Your manager has just confirmed the release timeline, but nobody has assigned the testing work.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-038',
  'CSF-038',
  1,
  null,
  'Your manager has just confirmed the release timeline, but nobody has assigned the testing work.',
  'We''ve agreed on the timeline, right?',
  'Confirm → Bridge → Purpose',
  'Yes, the dates look fine to me. That brings me to the next question: who''s handling the testing? We should lock that in today.',
  '{"id":"confirm-bridge-purpose","name":"Confirm → Bridge → Purpose","steps":[{"label":"Confirm","answer":"Yes, the dates look fine to me."},{"label":"Bridge","answer":"That brings me to the next question: who''s handling the testing?"},{"label":"Purpose","answer":"We should lock that in today."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-039', 'You need to ask about a different topic', 'Changing Topics', 'After chatting about your apartment, you want to ask a friend for travel advice.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-039',
  'CSF-039',
  1,
  null,
  'After chatting about your apartment, you want to ask a friend for travel advice.',
  'So how''s the new apartment?',
  'Answer → Shift → New topic',
  'It''s been great so far. Can we switch gears for a second? I actually wanted to ask you about your trip.',
  '{"id":"answer-shift-new-topic","name":"Answer → Shift → New topic","steps":[{"label":"Answer","answer":"It''s been great so far."},{"label":"Shift","answer":"Can we switch gears for a second?"},{"label":"New topic","answer":"I actually wanted to ask you about your trip."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-040', 'A customer thinks you canceled an appointment', 'Handling Misunderstandings', 'A customer believes their appointment was canceled, but you had moved it to Friday at their earlier request.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-040',
  'CSF-040',
  1,
  null,
  'A customer believes their appointment was canceled, but you had moved it to Friday at their earlier request.',
  'Why did you cancel my appointment?',
  'Flag → Explain → Offer',
  'I think there''s been a misunderstanding. I moved the appointment to Friday; I didn''t cancel it. Would you like me to send the updated confirmation?',
  '{"id":"flag-explain-offer","name":"Flag → Explain → Offer","steps":[{"label":"Flag","answer":"I think there''s been a misunderstanding."},{"label":"Explain","answer":"I moved the appointment to Friday; I didn''t cancel it."},{"label":"Offer","answer":"Would you like me to send the updated confirmation?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-041', 'A coworker thinks you want everything redone', 'Handling Misunderstandings', 'You ask a teammate to revise part of a report, but they think you''re rejecting the entire draft.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-041',
  'CSF-041',
  1,
  null,
  'You ask a teammate to revise part of a report, but they think you''re rejecting the entire draft.',
  'So you want me to redo the whole thing?',
  'Correct → Scope → Reassure',
  'That''s not quite what I meant. I only need you to update the first section. The rest looks good as it is.',
  '{"id":"correct-scope-reassure","name":"Correct → Scope → Reassure","steps":[{"label":"Correct","answer":"That''s not quite what I meant."},{"label":"Scope","answer":"I only need you to update the first section."},{"label":"Reassure","answer":"The rest looks good as it is."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-042', 'You explained a delivery fee poorly', 'Handling Misunderstandings', 'You''re helping a customer who thought every order qualified for free delivery.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-042',
  'CSF-042',
  1,
  null,
  'You''re helping a customer who thought every order qualified for free delivery.',
  'I thought delivery was free for everyone.',
  'Ownership → Rule → Exception',
  'I may not have explained that clearly. Delivery is free for orders over fifty dollars. For smaller orders, there''s a five-dollar fee.',
  '{"id":"ownership-rule-exception","name":"Ownership → Rule → Exception","steps":[{"label":"Ownership","answer":"I may not have explained that clearly."},{"label":"Rule","answer":"Delivery is free for orders over fifty dollars."},{"label":"Exception","answer":"For smaller orders, there''s a five-dollar fee."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-043', 'The team is discussing different payments', 'Handling Misunderstandings', 'A teammate says a payment was approved, but you were asking about the customer''s refund.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-043',
  'CSF-043',
  1,
  null,
  'A teammate says a payment was approved, but you were asking about the customer''s refund.',
  'The payment''s already been approved.',
  'Spot mismatch → Specify → Check',
  'We might be talking about two different things. I meant the refund request, not the original payment. Has the refund been approved yet?',
  '{"id":"spot-mismatch-specify-check","name":"Spot mismatch → Specify → Check","steps":[{"label":"Spot mismatch","answer":"We might be talking about two different things."},{"label":"Specify","answer":"I meant the refund request, not the original payment."},{"label":"Check","answer":"Has the refund been approved yet?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-044', 'The client expects an in-person meeting', 'Handling Misunderstandings', 'A client is planning to visit your office tomorrow, but the invitation is for a video call.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-044',
  'CSF-044',
  1,
  null,
  'A client is planning to visit your office tomorrow, but the invitation is for a video call.',
  'I thought tomorrow''s meeting was in person.',
  'Clarify → Evidence → Help',
  'Just to clear things up, tomorrow''s meeting is online. I sent the video link this morning. I can forward it again if that helps.',
  '{"id":"clarify-evidence-help","name":"Clarify → Evidence → Help","steps":[{"label":"Clarify","answer":"Just to clear things up, tomorrow''s meeting is online."},{"label":"Evidence","answer":"I sent the video link this morning."},{"label":"Help","answer":"I can forward it again if that helps."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-045', 'Two teams have different audiences in mind', 'Handling Misunderstandings', 'A teammate thinks an announcement will go to customers today, but today''s version is only for staff.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-045',
  'CSF-045',
  1,
  null,
  'A teammate thinks an announcement will go to customers today, but today''s version is only for staff.',
  'So are we sending this to everyone today?',
  'Align → Today → Later',
  'Let me make sure we''re on the same page. We''re sharing it with the internal team today, not customers. The customer email goes out next week.',
  '{"id":"align-today-later","name":"Align → Today → Later","steps":[{"label":"Align","answer":"Let me make sure we''re on the same page."},{"label":"Today","answer":"We''re sharing it with the internal team today, not customers."},{"label":"Later","answer":"The customer email goes out next week."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-046', 'You need to leave a cafe', 'Ending Conversations Naturally', 'You''ve had a nice chat over coffee, but you have an early morning and need to head home.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-046',
  'CSF-046',
  1,
  null,
  'You''ve had a nice chat over coffee, but you have an early morning and need to head home.',
  'Want to grab another coffee?',
  'Exit → Reason → Warm close',
  'I''d love to, but I should get going. I''ve got an early start tomorrow. Let''s catch up again soon.',
  '{"id":"exit-reason-warm-close","name":"Exit → Reason → Warm close","steps":[{"label":"Exit","answer":"I''d love to, but I should get going."},{"label":"Reason","answer":"I''ve got an early start tomorrow."},{"label":"Warm close","answer":"Let''s catch up again soon."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-047', 'A coworker has answered your question', 'Ending Conversations Naturally', 'You stopped by someone''s desk for a quick explanation, and they''ve finished helping you.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-047',
  'CSF-047',
  1,
  null,
  'You stopped by someone''s desk for a quick explanation, and they''ve finished helping you.',
  'Anything else you need?',
  'Confirm → Exit → Thanks',
  'No, that''s everything I needed. I''ll let you get back to it. Thanks for your help.',
  '{"id":"confirm-exit-thanks","name":"Confirm → Exit → Thanks","steps":[{"label":"Confirm","answer":"No, that''s everything I needed."},{"label":"Exit","answer":"I''ll let you get back to it."},{"label":"Thanks","answer":"Thanks for your help."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-048', 'You reconnect with an old classmate', 'Ending Conversations Naturally', 'You run into a former classmate, share updates, and are both about to leave.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-048',
  'CSF-048',
  1,
  null,
  'You run into a former classmate, share updates, and are both about to leave.',
  'We should do this again sometime.',
  'Warm close → Follow-up → Invitation',
  'Definitely, it was great catching up. I''ll send you a message next week. Let''s grab coffee when you''re free.',
  '{"id":"warm-close-follow-up-invitation","name":"Warm close → Follow-up → Invitation","steps":[{"label":"Warm close","answer":"Definitely, it was great catching up."},{"label":"Follow-up","answer":"I''ll send you a message next week."},{"label":"Invitation","answer":"Let''s grab coffee when you''re free."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-049', 'A client needs to join another meeting', 'Ending Conversations Naturally', 'You''re on a call with a client who has just mentioned their next meeting is starting.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-049',
  'CSF-049',
  1,
  null,
  'You''re on a call with a client who has just mentioned their next meeting is starting.',
  'I''m actually about to head into another meeting.',
  'Release → Next step → Thanks',
  'Of course, I won''t keep you any longer. I''ll send the details by email. Thanks for making time today.',
  '{"id":"release-next-step-thanks","name":"Release → Next step → Thanks","steps":[{"label":"Release","answer":"Of course, I won''t keep you any longer."},{"label":"Next step","answer":"I''ll send the details by email."},{"label":"Thanks","answer":"Thanks for making time today."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-050', 'A late call is running out of time', 'Ending Conversations Naturally', 'Your team is still discussing open points at the end of a long evening call.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-050',
  'CSF-050',
  1,
  null,
  'Your team is still discussing open points at the end of a long evening call.',
  'We still have a couple more things to discuss.',
  'Limit → Plan → Follow-through',
  'Yeah, but we''re running out of time. Let''s pick this up tomorrow. I''ll send over a quick summary tonight.',
  '{"id":"limit-plan-follow-through","name":"Limit → Plan → Follow-through","steps":[{"label":"Limit","answer":"Yeah, but we''re running out of time."},{"label":"Plan","answer":"Let''s pick this up tomorrow."},{"label":"Follow-through","answer":"I''ll send over a quick summary tonight."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-051', 'Your manager adds another urgent task', 'Negotiating & Boundaries', 'Your manager says a new report is top priority, but your other two deadlines have not changed.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-051',
  'CSF-051',
  1,
  null,
  'Your manager says a new report is top priority, but your other two deadlines have not changed.',
  'Can you make the new report your top priority today?',
  'Acknowledge → Priority → Commitment',
  'I understand this report is urgent. If this has to come first, what should I put on hold? I''ll adjust my plan once we''ve agreed on the order.',
  '{"id":"acknowledge-priority-commitment","name":"Acknowledge → Priority → Commitment","steps":[{"label":"Acknowledge","answer":"I understand this report is urgent."},{"label":"Priority","answer":"If this has to come first, what should I put on hold?"},{"label":"Commitment","answer":"I''ll adjust my plan once we''ve agreed on the order."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-052', 'You suggest a different way to meet the deadline', 'Negotiating & Boundaries', 'A colleague needs a long document today, but you can deliver the summary much sooner.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-052',
  'CSF-052',
  1,
  null,
  'A colleague needs a long document today, but you can deliver the summary much sooner.',
  'Can you finish the entire report before lunch?',
  'Need → Alternative → Next step',
  'I know you need something for the meeting. Would it work if I sent you the summary before lunch? I can send the full report later this afternoon.',
  '{"id":"need-alternative-next-step","name":"Need → Alternative → Next step","steps":[{"label":"Need","answer":"I know you need something for the meeting."},{"label":"Alternative","answer":"Would it work if I sent you the summary before lunch?"},{"label":"Next step","answer":"I can send the full report later this afternoon."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-053', 'You need to refuse an unreasonable request', 'Negotiating & Boundaries', 'A friend keeps asking you to stay longer, but you have to leave to collect a family member.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-053',
  'CSF-053',
  1,
  null,
  'A friend keeps asking you to stay longer, but you have to leave to collect a family member.',
  'Come on, can''t you stay another hour?',
  'Boundary → Reason → Warm close',
  'I''m afraid I can''t stay another hour. I promised to pick someone up soon. Let''s plan another evening when I''m free.',
  '{"id":"boundary-reason-warm-close","name":"Boundary → Reason → Warm close","steps":[{"label":"Boundary","answer":"I''m afraid I can''t stay another hour."},{"label":"Reason","answer":"I promised to pick someone up soon."},{"label":"Warm close","answer":"Let''s plan another evening when I''m free."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-054', 'The original solution is unavailable', 'Resolving Service Problems', 'Your hotel cannot offer the room type you paid for and only suggests waiting.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-054',
  'CSF-054',
  1,
  null,
  'Your hotel cannot offer the room type you paid for and only suggests waiting.',
  'Would you mind waiting another two hours?',
  'Constraint → Options → Need',
  'I was hoping to check in now. What other options do we have? Even a room where I can rest for a while would help.',
  '{"id":"constraint-options-need","name":"Constraint → Options → Need","steps":[{"label":"Constraint","answer":"I was hoping to check in now."},{"label":"Options","answer":"What other options do we have?"},{"label":"Need","answer":"Even a room where I can rest for a while would help."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-055', 'Front-desk staff cannot solve your issue', 'Resolving Service Problems', 'A store has charged you twice, and the cashier says they have no permission to adjust the payment.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-055',
  'CSF-055',
  1,
  null,
  'A store has charged you twice, and the cashier says they have no permission to adjust the payment.',
  'I can''t reverse a duplicate charge myself. Anything else I can do?',
  'Acknowledge → Escalate → Reason',
  'I understand you may not be able to change it yourself. Could I speak to someone who can help with this? I just need the duplicate charge checked.',
  '{"id":"acknowledge-escalate-reason","name":"Acknowledge → Escalate → Reason","steps":[{"label":"Acknowledge","answer":"I understand you may not be able to change it yourself."},{"label":"Escalate","answer":"Could I speak to someone who can help with this?"},{"label":"Reason","answer":"I just need the duplicate charge checked."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-056', 'You need to verify what was agreed', 'Clarifying Terms & Evidence', 'A colleague agrees to send final numbers by four, and the report depends on them.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-056',
  'CSF-056',
  1,
  null,
  'A colleague agrees to send final numbers by four, and the report depends on them.',
  'I''ll send the final figures later today, okay?',
  'Confirm → Scope → Reason',
  'Just to confirm, you''ll send the final numbers by four? And that''ll be the approved version, right? I need them to finish the report today.',
  '{"id":"confirm-scope-reason","name":"Confirm → Scope → Reason","steps":[{"label":"Confirm","answer":"Just to confirm, you''ll send the final numbers by four?"},{"label":"Scope","answer":"And that''ll be the approved version, right?"},{"label":"Reason","answer":"I need them to finish the report today."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-057', 'A friend thinks you never make time for them', 'Responding with Empathy', 'You have canceled plans twice because of work and your friend sounds hurt.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-057',
  'CSF-057',
  1,
  null,
  'You have canceled plans twice because of work and your friend sounds hurt.',
  'Do you even want to hang out anymore?',
  'Empathy → Ownership → Next step',
  'I can see why that''s frustrating. I''ve had to cancel twice, and I''m sorry about that. Could we pick a day next week that I can actually keep free?',
  '{"id":"empathy-ownership-next-step","name":"Empathy → Ownership → Next step","steps":[{"label":"Empathy","answer":"I can see why that''s frustrating."},{"label":"Ownership","answer":"I''ve had to cancel twice, and I''m sorry about that."},{"label":"Next step","answer":"Could we pick a day next week that I can actually keep free?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-058', 'You offer an immediate practical solution', 'Negotiating & Boundaries', 'Your teammate discovers the latest report has missing charts right before a meeting.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-058',
  'CSF-058',
  1,
  null,
  'Your teammate discovers the latest report has missing charts right before a meeting.',
  'Can you fix every chart before the meeting starts?',
  'Capacity → Action → Next step',
  'I can''t redo every chart in ten minutes. Here''s what I can do. I''ll fix the two key charts now and update the rest afterward.',
  '{"id":"capacity-action-next-step","name":"Capacity → Action → Next step","steps":[{"label":"Capacity","answer":"I can''t redo every chart in ten minutes."},{"label":"Action","answer":"Here''s what I can do."},{"label":"Next step","answer":"I''ll fix the two key charts now and update the rest afterward."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-059', 'You disagree without turning it into an argument', 'Negotiating & Boundaries', 'Your teammate suggests removing the testing step to meet a release date.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-059',
  'CSF-059',
  1,
  null,
  'Your teammate suggests removing the testing step to meet a release date.',
  'We don''t have time for testing. Can we skip it?',
  'Respect → Reason → Proposal',
  'I see your point, but I''d be careful about skipping testing. We could miss something serious right before release. Could we at least run the critical checks first?',
  '{"id":"respect-reason-proposal","name":"Respect → Reason → Proposal","steps":[{"label":"Respect","answer":"I see your point, but I''d be careful about skipping testing."},{"label":"Reason","answer":"We could miss something serious right before release."},{"label":"Proposal","answer":"Could we at least run the critical checks first?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-060', 'The process is unfamiliar and time-sensitive', 'Clarifying Terms & Evidence', 'Airport staff explain that you must recheck your luggage during a tight connection.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-060',
  'CSF-060',
  1,
  null,
  'Airport staff explain that you must recheck your luggage during a tight connection.',
  'You need to recheck your bag after immigration. Understood?',
  'Gap → Walkthrough → First action',
  'I''m not familiar with how that works here. Could you walk me through the steps? Where should I go first?',
  '{"id":"gap-walkthrough-first-action","name":"Gap → Walkthrough → First action","steps":[{"label":"Gap","answer":"I''m not familiar with how that works here."},{"label":"Walkthrough","answer":"Could you walk me through the steps?"},{"label":"First action","answer":"Where should I go first?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-061', 'A service offer may have hidden conditions', 'Clarifying Terms & Evidence', 'A hotel offers an alternative room, but you are unsure whether breakfast is still part of your booking.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-061',
  'CSF-061',
  1,
  null,
  'A hotel offers an alternative room, but you are unsure whether breakfast is still part of your booking.',
  'I can move you to this other room. Would you like it?',
  'Acknowledge → Condition → Confirm',
  'That might work for me. Does that include breakfast like my original booking? I''d just like to check before I agree.',
  '{"id":"acknowledge-condition-confirm","name":"Acknowledge → Condition → Confirm","steps":[{"label":"Acknowledge","answer":"That might work for me."},{"label":"Condition","answer":"Does that include breakfast like my original booking?"},{"label":"Confirm","answer":"I''d just like to check before I agree."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-062', 'Someone pressures you to guess an important figure', 'Clarifying Terms & Evidence', 'A client asks for the latest conversion rate during a meeting before the dashboard refresh is complete.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-062',
  'CSF-062',
  1,
  null,
  'A client asks for the latest conversion rate during a meeting before the dashboard refresh is complete.',
  'Can you just give me a number now?',
  'Uncertainty → Reason → Follow-up',
  'I don''t have that information yet. I want to verify it against the latest dashboard. Can I send you the confirmed rate right after this meeting?',
  '{"id":"uncertainty-reason-follow-up","name":"Uncertainty → Reason → Follow-up","steps":[{"label":"Uncertainty","answer":"I don''t have that information yet."},{"label":"Reason","answer":"I want to verify it against the latest dashboard."},{"label":"Follow-up","answer":"Can I send you the confirmed rate right after this meeting?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-063', 'A stranger asks a private question', 'Negotiating & Boundaries', 'An acquaintance at a party repeatedly asks how much you earn.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-063',
  'CSF-063',
  1,
  null,
  'An acquaintance at a party repeatedly asks how much you earn.',
  'Why don''t you just tell me your exact salary?',
  'Boundary → Tone → Redirect',
  'I''d rather keep that private. Nothing personal; I just don''t discuss money much. How''s work been going for you lately?',
  '{"id":"boundary-tone-redirect","name":"Boundary → Tone → Redirect","steps":[{"label":"Boundary","answer":"I''d rather keep that private."},{"label":"Tone","answer":"Nothing personal; I just don''t discuss money much."},{"label":"Redirect","answer":"How''s work been going for you lately?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-064', 'You negotiate a fair middle option', 'Negotiating & Boundaries', 'You and your friend cannot agree on a time to leave for a day trip.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-064',
  'CSF-064',
  1,
  null,
  'You and your friend cannot agree on a time to leave for a day trip.',
  'Can we leave at six in the morning?',
  'Acknowledge → Compromise → Proposal',
  'I get why you want an early start. Could we meet halfway? How about leaving at seven instead?',
  '{"id":"acknowledge-compromise-proposal","name":"Acknowledge → Compromise → Proposal","steps":[{"label":"Acknowledge","answer":"I get why you want an early start."},{"label":"Compromise","answer":"Could we meet halfway?"},{"label":"Proposal","answer":"How about leaving at seven instead?"}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-065', 'You need to back up a broad opinion', 'Clarifying Terms & Evidence', 'During a design review, a colleague asks why you think the checkout page is confusing.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-065',
  'CSF-065',
  1,
  null,
  'During a design review, a colleague asks why you think the checkout page is confusing.',
  'What makes you say the checkout page is confusing?',
  'Issue → Example → Impact',
  'The main action is hard to spot. For example, the payment button is below three large banners. That makes it easy for people to miss the next step.',
  '{"id":"issue-example-impact","name":"Issue → Example → Impact","steps":[{"label":"Issue","answer":"The main action is hard to spot."},{"label":"Example","answer":"For example, the payment button is below three large banners."},{"label":"Impact","answer":"That makes it easy for people to miss the next step."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('CSF-066', 'You follow up on a missing delivery', 'Resolving Service Problems', 'You reported a missing package yesterday but have not heard back.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'CSF-066',
  'CSF-066',
  1,
  null,
  'You reported a missing package yesterday but have not heard back.',
  'Hi again. What can I help you with today?',
  'Reference → Update → Help',
  'I''m following up on the package I reported missing yesterday. Any update on the investigation? I can give you the tracking number again if needed.',
  '{"id":"reference-update-help","name":"Reference → Update → Help","steps":[{"label":"Reference","answer":"I''m following up on the package I reported missing yesterday."},{"label":"Update","answer":"Any update on the investigation?"},{"label":"Help","answer":"I can give you the tracking number again if needed."}]}'::jsonb,
  null,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-001', 'An unrealistic deadline', 'Workplace', 'Your manager assigns a report due tomorrow, but you already have two urgent tasks.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-001',
  'SCN-001',
  1,
  null,
  'Your manager assigns a report due tomorrow, but you already have two urgent tasks.',
  'Can you finish this by tomorrow?',
  'Capacity → Constraint → Proposal',
  'I can start on it today, no problem. The thing is, I''ve already got two urgent tasks on my plate. Could we push the deadline to Thursday?',
  '{"id":"capacity-constraint-proposal","name":"Capacity → Constraint → Proposal","steps":[{"label":"Capacity","answer":"I can start on it today, no problem."},{"label":"Constraint","answer":"The thing is, I''ve already got two urgent tasks on my plate."},{"label":"Proposal","answer":"Could we push the deadline to Thursday?"}]}'::jsonb,
  '[{"speaker":"Manager","question":"Thursday is too late. What could you deliver by tomorrow?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Manager","question":"If this report has to come first, which of your other tasks can wait?","decks":[{"code":"CSF-051","phrase":"If this has to come first, what should I put on hold?"},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Manager","question":"Why can''t you just stay late and finish all three tasks?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-059","phrase":"I see your point, but..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-002', 'Your coworker says "ASAP"', 'Workplace', 'Your coworker messages "Need this ASAP" but never tells you when it is actually due.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-002',
  'SCN-002',
  1,
  null,
  'Your coworker messages "Need this ASAP" but never tells you when it is actually due.',
  'Can you get this to me ASAP?',
  'Agree → Clarify → Act',
  'Sure, I can take a look. Quick question, when do you actually need it? I can send it over by three if that works.',
  '{"id":"agree-clarify-act","name":"Agree → Clarify → Act","steps":[{"label":"Agree","answer":"Sure, I can take a look."},{"label":"Clarify","answer":"Quick question, when do you actually need it?"},{"label":"Act","answer":"I can send it over by three if that works."}]}'::jsonb,
  '[{"speaker":"Coworker","question":"I actually need this by noon. Could you make that work?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-051","phrase":"If this has to come first, what should I put on hold?"}]},{"speaker":"Coworker","question":"When you say you can send it, do you mean the draft or the final version?","decks":[{"code":"CSF-007","phrase":"Did you mean..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Coworker","question":"It''s for our one o''clock meeting. Could you send me just the summary first?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-052","phrase":"Would it work if..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-003', 'Politely disagreeing', 'Workplace', 'A coworker suggests removing all customer feedback from the next product review.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-003',
  'SCN-003',
  1,
  null,
  'A coworker suggests removing all customer feedback from the next product review.',
  'Should we skip customer feedback this time?',
  'Position → Reason → Example',
  'I see what you mean, but I''d keep the customer feedback. It''s how we find out what''s not working. Remember that search issue it helped us catch?',
  '{"id":"position-reason-example","name":"Position → Reason → Example","steps":[{"label":"Position","answer":"I see what you mean, but I''d keep the customer feedback."},{"label":"Reason","answer":"It''s how we find out what''s not working."},{"label":"Example","answer":"Remember that search issue it helped us catch?"}]}'::jsonb,
  '[{"speaker":"Coworker","question":"But won''t the customer feedback make the review too long?","decks":[{"code":"CSF-059","phrase":"I see your point, but..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Coworker","question":"What specific customer comment helped us find that search issue?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-012","phrase":"Off the top of my head..."}]},{"speaker":"Coworker","question":"So are you saying my idea is bad?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-016","phrase":"What I''m trying to say is..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-004', 'Joining a meeting late', 'Workplace', 'You join an online meeting five minutes late because your previous call ran over.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-004',
  'SCN-004',
  1,
  null,
  'You join an online meeting five minutes late because your previous call ran over.',
  'Hey, you just joined. Everything okay?',
  'Apology → Reason → Catch-up',
  'Sorry I''m late, guys. My last call ran longer than I expected. Can someone quickly catch me up?',
  '{"id":"apology-reason-catch-up","name":"Apology → Reason → Catch-up","steps":[{"label":"Apology","answer":"Sorry I''m late, guys."},{"label":"Reason","answer":"My last call ran longer than I expected."},{"label":"Catch-up","answer":"Can someone quickly catch me up?"}]}'::jsonb,
  '[{"speaker":"Colleague","question":"We just approved the revised budget. Do you need us to repeat the figure?","decks":[{"code":"CSF-006","phrase":"Just to make sure I''ve got this right..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Colleague","question":"We''re almost out of time. Can you read the meeting notes afterward?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Colleague","question":"Wait, I thought you had already seen the meeting notes. Haven''t you?","decks":[{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."},{"code":"CSF-018","phrase":"That came out wrong."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-005', 'Your boss says your slides are confusing', 'Workplace', 'Your manager says the slides you spent all morning on are confusing, right before a client call.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-005',
  'SCN-005',
  1,
  null,
  'Your manager says the slides you spent all morning on are confusing, right before a client call.',
  'These slides are kind of confusing, don’t you think?',
  'Request → Focus → Timing',
  'Yeah, I see what you mean. Which part feels the hardest to follow? I can clean that up before the call.',
  '{"id":"request-focus-timing","name":"Request → Focus → Timing","steps":[{"label":"Request","answer":"Yeah, I see what you mean."},{"label":"Focus","answer":"Which part feels the hardest to follow?"},{"label":"Timing","answer":"I can clean that up before the call."}]}'::jsonb,
  '[{"speaker":"Manager","question":"Slide four is too crowded. Can you fix it before the client joins?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Manager","question":"I can''t point to one slide; the whole story just feels off. Can you help?","decks":[{"code":"CSF-005","phrase":"Could you give me an example?"},{"code":"CSF-060","phrase":"Could you walk me through...?"}]},{"speaker":"Manager","question":"We need to keep every chart. Is there still a way to make this clearer?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-059","phrase":"I see your point, but..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-006', 'You sent the wrong attachment', 'Workplace', 'You realize you sent the old version of a report to the team ten minutes ago.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-006',
  'SCN-006',
  1,
  null,
  'You realize you sent the old version of a report to the team ten minutes ago.',
  'Is this the final version you just emailed?',
  'Flag → Fix → Timing',
  'My bad, I attached the old version. I caught it right after I hit send. I''ll send the right file over now.',
  '{"id":"flag-fix-timing","name":"Flag → Fix → Timing","steps":[{"label":"Flag","answer":"My bad, I attached the old version."},{"label":"Fix","answer":"I caught it right after I hit send."},{"label":"Timing","answer":"I''ll send the right file over now."}]}'::jsonb,
  '[{"speaker":"Manager","question":"Did anyone outside our team receive the old report?","decks":[{"code":"CSF-062","phrase":"I don''t have that information yet."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Manager","question":"What will you change so this doesn''t happen again?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-065","phrase":"For example..."}]},{"speaker":"Manager","question":"Can you replace the wrong file in the shared folder as well?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-007', 'Declining an extra task', 'Workplace', 'A teammate asks for help, but you''re already busy finishing a high-priority task.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-007',
  'SCN-007',
  1,
  null,
  'A teammate asks for help, but you''re already busy finishing a high-priority task.',
  'Could you help me with this right now?',
  'Willingness → Constraint → Alternative',
  'I''d love to help, but I''m swamped right now. I''ve got something due today that I need to finish first. Can we go over it after three?',
  '{"id":"willingness-constraint-alternative","name":"Willingness → Constraint → Alternative","steps":[{"label":"Willingness","answer":"I''d love to help, but I''m swamped right now."},{"label":"Constraint","answer":"I''ve got something due today that I need to finish first."},{"label":"Alternative","answer":"Can we go over it after three?"}]}'::jsonb,
  '[{"speaker":"Teammate","question":"Even five minutes would help. Could you just take a quick look?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Teammate","question":"Okay, would three thirty work instead?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-010","phrase":"Can I get back to you on that?"}]},{"speaker":"Teammate","question":"It feels like you''re always too busy to help me. Is that fair?","decks":[{"code":"CSF-057","phrase":"I can see why that''s frustrating."},{"code":"CSF-058","phrase":"Here''s what I can do."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-008', 'Asking someone to speak slower', 'Workplace', 'During a video call, a colleague is speaking too quickly for you to follow.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-008',
  'SCN-008',
  1,
  null,
  'During a video call, a colleague is speaking too quickly for you to follow.',
  'Does that make sense so far?',
  'Acknowledge → Difficulty → Request',
  'I think I get the big picture. I''m having a hard time keeping up with all the steps, though. Could you slow down a little on that last part?',
  '{"id":"acknowledge-difficulty-request","name":"Acknowledge → Difficulty → Request","steps":[{"label":"Acknowledge","answer":"I think I get the big picture."},{"label":"Difficulty","answer":"I''m having a hard time keeping up with all the steps, though."},{"label":"Request","answer":"Could you slow down a little on that last part?"}]}'::jsonb,
  '[{"speaker":"Colleague","question":"Sure. Which step should I go through again?","decks":[{"code":"CSF-060","phrase":"Could you walk me through...?"},{"code":"CSF-002","phrase":"Could you say that a little more slowly?"}]},{"speaker":"Colleague","question":"I only have two minutes left. Could you review the recording later?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Colleague","question":"Would you like the technical details again or just a high-level summary?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-003","phrase":"What do you mean by..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-009', 'Everyone thinks you booked the room', 'Workplace', 'Your team shows up for a client meeting, but the room is not booked and everyone thinks you handled it.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-009',
  'SCN-009',
  1,
  null,
  'Your team shows up for a client meeting, but the room is not booked and everyone thinks you handled it.',
  'Wait, did you book the meeting room?',
  'Answer → Understanding → Offer',
  'I thought Alex was taking care of that. Looks like we got our wires crossed. Let me see if there''s another room free.',
  '{"id":"answer-understanding-offer","name":"Answer → Understanding → Offer","steps":[{"label":"Answer","answer":"I thought Alex was taking care of that."},{"label":"Understanding","answer":"Looks like we got our wires crossed."},{"label":"Offer","answer":"Let me see if there''s another room free."}]}'::jsonb,
  '[{"speaker":"Coworker","question":"Alex isn''t here yet. Can you find a room for six people?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-054","phrase":"What other options do we have?"}]},{"speaker":"Coworker","question":"Why did you think Alex was taking care of the booking?","decks":[{"code":"CSF-016","phrase":"What I''m trying to say is..."},{"code":"CSF-065","phrase":"For example..."}]},{"speaker":"Coworker","question":"The client is already online. Could we start the meeting virtually instead?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-010', 'Handling an unexpected question', 'Workplace', 'In a meeting, a client asks for a number you haven''t verified.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-010',
  'SCN-010',
  1,
  null,
  'In a meeting, a client asks for a number you haven''t verified.',
  'What''s the exact number of active users this month?',
  'Honesty → Reason → Commitment',
  'I don''t want to give you the wrong number. Let me double-check this month''s figures first. Can I send you the exact number right after the meeting?',
  '{"id":"honesty-reason-commitment","name":"Honesty → Reason → Commitment","steps":[{"label":"Honesty","answer":"I don''t want to give you the wrong number."},{"label":"Reason","answer":"Let me double-check this month''s figures first."},{"label":"Commitment","answer":"Can I send you the exact number right after the meeting?"}]}'::jsonb,
  '[{"speaker":"Client","question":"Could you give us a rough estimate for now?","decks":[{"code":"CSF-062","phrase":"I don''t have that information yet."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Client","question":"Why didn''t you have that number ready for this meeting?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-042","phrase":"I may not have explained that clearly."}]},{"speaker":"Client","question":"Could you include weekly active users in your follow-up too?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-011', 'Food is taking too long', 'Restaurant & Cafe', 'You''re at a restaurant in New York. You ordered 30 minutes ago, but your food hasn''t arrived.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-011',
  'SCN-011',
  1,
  null,
  'You''re at a restaurant in New York. You ordered 30 minutes ago, but your food hasn''t arrived.',
  'Is everything okay with your order?',
  'Problem → Context → Request',
  'Hey, just checking in—our food still hasn''t come out. It''s been about half an hour since we ordered. Could you see what''s going on?',
  '{"id":"problem-context-request","name":"Problem → Context → Request","steps":[{"label":"Problem","answer":"Hey, just checking in—our food still hasn''t come out."},{"label":"Context","answer":"It''s been about half an hour since we ordered."},{"label":"Request","answer":"Could you see what''s going on?"}]}'::jsonb,
  '[{"speaker":"Waiter","question":"The kitchen says it''ll be another ten minutes. Is that okay?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Waiter","question":"I''m sorry, I can''t find the order. What did you have?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-065","phrase":"For example..."}]},{"speaker":"Waiter","question":"Would you rather cancel the order and get a refund?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-052","phrase":"Would it work if..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-012', 'You received the wrong drink', 'Restaurant & Cafe', 'You ordered an iced latte, but the barista hands you a hot cappuccino.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-012',
  'SCN-012',
  1,
  null,
  'You ordered an iced latte, but the barista hands you a hot cappuccino.',
  'Here''s your cappuccino. Anything else?',
  'Soft correction → Clarification → Request',
  'Oh, I think there''s been a mix-up. I ordered an iced latte, not a hot cappuccino. Could you swap it for the iced one?',
  '{"id":"soft-correction-clarification-request","name":"Soft correction → Clarification → Request","steps":[{"label":"Soft correction","answer":"Oh, I think there''s been a mix-up."},{"label":"Clarification","answer":"I ordered an iced latte, not a hot cappuccino."},{"label":"Request","answer":"Could you swap it for the iced one?"}]}'::jsonb,
  '[{"speaker":"Barista","question":"Are you sure? Our register says you ordered a cappuccino. Could you check your receipt?","decks":[{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Barista","question":"The iced latte will take ten more minutes. Is that all right?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Barista","question":"Would you like the same size and milk you originally requested?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-007","phrase":"Did you mean..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-013', 'A dish contains an allergen', 'Restaurant & Cafe', 'You have a peanut allergy and want to confirm the ingredients before ordering.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-013',
  'SCN-013',
  1,
  null,
  'You have a peanut allergy and want to confirm the ingredients before ordering.',
  'Would you like to try our house special?',
  'Allergy → Risk → Check',
  'That sounds good, but I have a peanut allergy. I''m not sure if the sauce has peanuts in it. Could you check with the kitchen before I order?',
  '{"id":"allergy-risk-check","name":"Allergy → Risk → Check","steps":[{"label":"Allergy","answer":"That sounds good, but I have a peanut allergy."},{"label":"Risk","answer":"I''m not sure if the sauce has peanuts in it."},{"label":"Check","answer":"Could you check with the kitchen before I order?"}]}'::jsonb,
  '[{"speaker":"Waiter","question":"It has no peanuts in the recipe, but we use shared equipment. Is that safe for you?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Waiter","question":"The chef can''t confirm every ingredient in the sauce. Do you want to order anyway?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-054","phrase":"What other options do we have?"}]},{"speaker":"Waiter","question":"We have a different dish. Would you like me to check its ingredients and preparation too?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-061","phrase":"Does that include...?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-014', 'The wait is forty minutes and you are starving', 'Restaurant & Cafe', 'You and a friend walk into a packed restaurant after a long day. The host says the wait is forty minutes.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-014',
  'SCN-014',
  1,
  null,
  'You and a friend walk into a packed restaurant after a long day. The host says the wait is forty minutes.',
  'Is a forty-minute wait okay?',
  'Reaction → Flexibility → Option',
  'Oof, that''s a pretty long wait. We''re fine with sitting at the bar, though. Would that be any faster?',
  '{"id":"reaction-flexibility-option","name":"Reaction → Flexibility → Option","steps":[{"label":"Reaction","answer":"Oof, that''s a pretty long wait."},{"label":"Flexibility","answer":"We''re fine with sitting at the bar, though."},{"label":"Option","answer":"Would that be any faster?"}]}'::jsonb,
  '[{"speaker":"Host","question":"Two seats are open at the bar right now, but they''re near the kitchen. Interested?","decks":[{"code":"CSF-061","phrase":"Does that include...?"},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Host","question":"We don''t serve full meals at the bar. Would you still like to wait forty minutes?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Host","question":"I can''t hold your place if you leave. Do you want to stay on the list?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-054","phrase":"What other options do we have?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-015', 'A missing item in a takeaway order', 'Restaurant & Cafe', 'You open your takeaway bag and realize the fries you paid for are missing.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-015',
  'SCN-015',
  1,
  null,
  'You open your takeaway bag and realize the fries you paid for are missing.',
  'Hi! What can I help you with?',
  'Missing item → Evidence → Request',
  'Hey, I think you forgot my fries. I paid for them, but they''re not in the bag. Could you grab them for me?',
  '{"id":"missing-item-evidence-request","name":"Missing item → Evidence → Request","steps":[{"label":"Missing item","answer":"Hey, I think you forgot my fries."},{"label":"Evidence","answer":"I paid for them, but they''re not in the bag."},{"label":"Request","answer":"Could you grab them for me?"}]}'::jsonb,
  '[{"speaker":"Cashier","question":"Do you have the receipt showing the fries?","decks":[{"code":"CSF-011","phrase":"Give me a moment to check."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Cashier","question":"I''m sorry, we''re out of fries. Would you like something else?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Cashier","question":"Only the manager can authorize a refund. Would you like me to call them?","decks":[{"code":"CSF-055","phrase":"Could I speak to someone who can help with this?"},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-016', 'Split the bill', 'Restaurant & Cafe', 'You''re having dinner with friends and need to pay separately.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-016',
  'SCN-016',
  1,
  null,
  'You''re having dinner with friends and need to pay separately.',
  'Are you paying together today?',
  'Answer → Detail → Request',
  'Could we do separate checks, please? There are three of us at the table. Could you split it three ways?',
  '{"id":"answer-detail-request","name":"Answer → Detail → Request","steps":[{"label":"Answer","answer":"Could we do separate checks, please?"},{"label":"Detail","answer":"There are three of us at the table."},{"label":"Request","answer":"Could you split it three ways?"}]}'::jsonb,
  '[{"speaker":"Waiter","question":"Do you mean three equal payments or each person paying for their own food?","decks":[{"code":"CSF-016","phrase":"What I''m trying to say is..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Waiter","question":"Our system can only take one payment for this table. What would you like to do?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Waiter","question":"There''s an extra dessert on the bill. Does anyone know who ordered it?","decks":[{"code":"CSF-011","phrase":"Give me a moment to check."},{"code":"CSF-061","phrase":"Does that include...?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-017', 'Request a less spicy meal', 'Restaurant & Cafe', 'You''re ordering a dish but cannot eat very spicy food.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-017',
  'SCN-017',
  1,
  null,
  'You''re ordering a dish but cannot eat very spicy food.',
  'How spicy would you like it?',
  'Preference → Limit → Request',
  'Could you make it really mild, please? I''m not great with spicy food. Maybe skip the extra chili?',
  '{"id":"preference-limit-request","name":"Preference → Limit → Request","steps":[{"label":"Preference","answer":"Could you make it really mild, please?"},{"label":"Limit","answer":"I''m not great with spicy food."},{"label":"Request","answer":"Maybe skip the extra chili?"}]}'::jsonb,
  '[{"speaker":"Waiter","question":"Medium is our mildest spice level. Would that be okay?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-054","phrase":"What other options do we have?"}]},{"speaker":"Waiter","question":"I can remove the chili, but the sauce is still hot. Would you prefer another sauce?","decks":[{"code":"CSF-061","phrase":"Does that include...?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Waiter","question":"Just to confirm, do you want no extra chili at all?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-007","phrase":"Did you mean..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-018', 'The waiter keeps pushing dessert', 'Restaurant & Cafe', 'You are completely full, but the friendly waiter comes back to recommend dessert again.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-018',
  'SCN-018',
  1,
  null,
  'You are completely full, but the friendly waiter comes back to recommend dessert again.',
  'Would you like to try the cheesecake?',
  'Appreciation → Decline → Close',
  'It sounds great, but I''m stuffed. Maybe next time. Could we just get the check, please?',
  '{"id":"appreciation-decline-close","name":"Appreciation → Decline → Close","steps":[{"label":"Appreciation","answer":"It sounds great, but I''m stuffed."},{"label":"Decline","answer":"Maybe next time."},{"label":"Close","answer":"Could we just get the check, please?"}]}'::jsonb,
  '[{"speaker":"Waiter","question":"We also have a tiny dessert to share. Sure you don''t want it?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-046","phrase":"I should get going."}]},{"speaker":"Waiter","question":"Of course. Would you like one check for the whole table?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Waiter","question":"I''m sorry, did you say you''re ready to pay now?","decks":[{"code":"CSF-006","phrase":"Just to make sure I''ve got this right..."},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-019', 'Declining a party invitation', 'Social Life', 'Your friends invite you out tonight, but you''re exhausted after a long workday.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-019',
  'SCN-019',
  1,
  null,
  'Your friends invite you out tonight, but you''re exhausted after a long workday.',
  'Are you coming out with us tonight?',
  'Warmth → Reason → Alternative',
  'Aw, thanks for asking me! I''m totally wiped out from work today. Can I take a rain check?',
  '{"id":"warmth-reason-alternative","name":"Warmth → Reason → Alternative","steps":[{"label":"Warmth","answer":"Aw, thanks for asking me!"},{"label":"Reason","answer":"I''m totally wiped out from work today."},{"label":"Alternative","answer":"Can I take a rain check?"}]}'::jsonb,
  '[{"speaker":"Friend","question":"How about coming for just one drink?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Friend","question":"No problem. Are you free on Sunday instead?","decks":[{"code":"CSF-010","phrase":"Can I get back to you on that?"},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Friend","question":"Is everything okay? You seem a little down. Do you want to talk about it?","decks":[{"code":"CSF-063","phrase":"I''d rather keep that private."},{"code":"CSF-018","phrase":"That came out wrong."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-020', 'Someone asks a personal question', 'Social Life', 'At a gathering, someone you''ve just met asks how much money you earn.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-020',
  'SCN-020',
  1,
  null,
  'At a gathering, someone you''ve just met asks how much money you earn.',
  'So, how much do you make?',
  'Light reaction → Boundary → Redirect',
  'Wow, straight to the personal questions, huh? I''d rather not get into my salary. So, what do you do for work?',
  '{"id":"light-reaction-boundary-redirect","name":"Light reaction → Boundary → Redirect","steps":[{"label":"Light reaction","answer":"Wow, straight to the personal questions, huh?"},{"label":"Boundary","answer":"I''d rather not get into my salary."},{"label":"Redirect","answer":"So, what do you do for work?"}]}'::jsonb,
  '[{"speaker":"Acquaintance","question":"Come on, it''s just a number. Why won''t you tell me?","decks":[{"code":"CSF-063","phrase":"I''d rather keep that private."},{"code":"CSF-053","phrase":"I''m afraid I can''t..."}]},{"speaker":"Acquaintance","question":"Fair enough. So what kind of work do you do?","decks":[{"code":"CSF-022","phrase":"How about you?"},{"code":"CSF-024","phrase":"Tell me more about that."}]},{"speaker":"Acquaintance","question":"Wait, does that mean you aren''t happy with your salary?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-016","phrase":"What I''m trying to say is..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-021', 'You forgot their name again', 'Social Life', 'Someone you met twice comes over at a party and greets you like an old friend, but their name has completely slipped your mind.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-021',
  'SCN-021',
  1,
  null,
  'Someone you met twice comes over at a party and greets you like an old friend, but their name has completely slipped your mind.',
  'Hey! You remember me, right?',
  'Recognition → Admission → Request',
  'Of course, we''ve met before! Your name totally slipped my mind, though. Can you remind me real quick?',
  '{"id":"recognition-admission-request","name":"Recognition → Admission → Request","steps":[{"label":"Recognition","answer":"Of course, we''ve met before!"},{"label":"Admission","answer":"Your name totally slipped my mind, though."},{"label":"Request","answer":"Can you remind me real quick?"}]}'::jsonb,
  '[{"speaker":"Acquaintance","question":"It''s Jamie. Remember meeting at Sam''s birthday party?","decks":[{"code":"CSF-006","phrase":"Just to make sure I''ve got this right..."},{"code":"CSF-027","phrase":"You mentioned..."}]},{"speaker":"Acquaintance","question":"No worries. Have you been back to that little cafe we visited?","decks":[{"code":"CSF-022","phrase":"How about you?"},{"code":"CSF-023","phrase":"What was that like?"}]},{"speaker":"Acquaintance","question":"You forgot my name again? Seriously?","decks":[{"code":"CSF-057","phrase":"I can see why that''s frustrating."},{"code":"CSF-018","phrase":"That came out wrong."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-022', 'Making small talk after a long time', 'Social Life', 'You run into a former classmate you haven''t seen for years.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-022',
  'SCN-022',
  1,
  null,
  'You run into a former classmate you haven''t seen for years.',
  'Wow, it''s been ages! What have you been up to?',
  'Update → Personal detail → Ask back',
  'Oh man, it''s been forever! I''ve been busy with work, but I finally got into photography. What about you—what have you been up to?',
  '{"id":"update-personal-detail-ask-back","name":"Update → Personal detail → Ask back","steps":[{"label":"Update","answer":"Oh man, it''s been forever!"},{"label":"Personal detail","answer":"I''ve been busy with work, but I finally got into photography."},{"label":"Ask back","answer":"What about you—what have you been up to?"}]}'::jsonb,
  '[{"speaker":"Classmate","question":"Photography? What got you interested in that?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-022","phrase":"How about you?"}]},{"speaker":"Classmate","question":"I''ve actually been traveling a lot for work. Want to hear about it?","decks":[{"code":"CSF-023","phrase":"What was that like?"},{"code":"CSF-024","phrase":"Tell me more about that."}]},{"speaker":"Classmate","question":"Are you still in touch with anyone from our old class?","decks":[{"code":"CSF-035","phrase":"Speaking of..."},{"code":"CSF-027","phrase":"You mentioned..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-023', 'Changing weekend plans', 'Social Life', 'Your friend wants to go hiking, but the weather forecast predicts heavy rain.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-023',
  'SCN-023',
  1,
  null,
  'Your friend wants to go hiking, but the weather forecast predicts heavy rain.',
  'Are we still going hiking on Saturday?',
  'Concern → Consequence → Suggestion',
  'I hate to say it, but Saturday looks pretty rainy. I don''t think a hike in that weather would be much fun. Want to grab brunch instead?',
  '{"id":"concern-consequence-suggestion","name":"Concern → Consequence → Suggestion","steps":[{"label":"Concern","answer":"I hate to say it, but Saturday looks pretty rainy."},{"label":"Consequence","answer":"I don''t think a hike in that weather would be much fun."},{"label":"Suggestion","answer":"Want to grab brunch instead?"}]}'::jsonb,
  '[{"speaker":"Friend","question":"It''s only supposed to drizzle. Why cancel the hike?","decks":[{"code":"CSF-059","phrase":"I see your point, but..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Friend","question":"Brunch sounds great. Do you know where we should go?","decks":[{"code":"CSF-010","phrase":"Can I get back to you on that?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Friend","question":"I can''t do brunch, but Sunday looks sunny. Could we hike then?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-052","phrase":"Would it work if..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-024', 'You are stuck in a never-ending conversation', 'Social Life', 'At a work event, someone keeps talking while your ride is already waiting outside.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-024',
  'SCN-024',
  1,
  null,
  'At a work event, someone keeps talking while your ride is already waiting outside.',
  'Anyway, should I tell you what happened next?',
  'Answer → Exit → Warm close',
  'I''d love to hear the rest, honestly. But my ride''s already outside, so I gotta run. Let''s catch up another time!',
  '{"id":"answer-exit-warm-close","name":"Answer → Exit → Warm close","steps":[{"label":"Answer","answer":"I''d love to hear the rest, honestly."},{"label":"Exit","answer":"But my ride''s already outside, so I gotta run."},{"label":"Warm close","answer":"Let''s catch up another time!"}]}'::jsonb,
  '[{"speaker":"Acquaintance","question":"Wait, one last thing. Can I tell you how the story ends?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-048","phrase":"It was great catching up."}]},{"speaker":"Acquaintance","question":"No worries. When would be a good time to catch up again?","decks":[{"code":"CSF-010","phrase":"Can I get back to you on that?"},{"code":"CSF-048","phrase":"It was great catching up."}]},{"speaker":"Acquaintance","question":"Are you leaving because I''m boring you?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-018","phrase":"That came out wrong."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-025', 'Disagreeing about a movie', 'Social Life', 'A friend loved a movie you thought was boring.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-025',
  'SCN-025',
  1,
  null,
  'A friend loved a movie you thought was boring.',
  'Wasn''t that movie amazing?',
  'Respect → Different view → Detail',
  'I get why you liked it. Honestly, it wasn''t really my thing. The middle felt a little too slow for me.',
  '{"id":"respect-different-view-detail","name":"Respect → Different view → Detail","steps":[{"label":"Respect","answer":"I get why you liked it."},{"label":"Different view","answer":"Honestly, it wasn''t really my thing."},{"label":"Detail","answer":"The middle felt a little too slow for me."}]}'::jsonb,
  '[{"speaker":"Friend","question":"Really? Which part of the movie felt slow to you?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-012","phrase":"Off the top of my head..."}]},{"speaker":"Friend","question":"So you think I have bad taste in movies?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Friend","question":"What film would you recommend instead?","decks":[{"code":"CSF-012","phrase":"Off the top of my head..."},{"code":"CSF-022","phrase":"How about you?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-026', 'You laughed at a joke you did not get', 'Social Life', 'Everyone laughs at a joke, so you laugh too. Then your friend asks whether you actually understood it.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-026',
  'SCN-026',
  1,
  null,
  'Everyone laughs at a joke, so you laugh too. Then your friend asks whether you actually understood it.',
  'Be honest, did you even get that joke?',
  'Honesty → Missing piece → Request',
  'Not gonna lie, I kind of missed it. Everyone laughed, so I just went along with it. What was the punchline again?',
  '{"id":"honesty-missing-piece-request","name":"Honesty → Missing piece → Request","steps":[{"label":"Honesty","answer":"Not gonna lie, I kind of missed it."},{"label":"Missing piece","answer":"Everyone laughed, so I just went along with it."},{"label":"Request","answer":"What was the punchline again?"}]}'::jsonb,
  '[{"speaker":"Friend","question":"It was a pun on the word ''bank.'' Do you get it now?","decks":[{"code":"CSF-003","phrase":"What do you mean by..."},{"code":"CSF-060","phrase":"Could you walk me through...?"}]},{"speaker":"Friend","question":"Which part of the joke didn''t you understand?","decks":[{"code":"CSF-007","phrase":"Did you mean..."},{"code":"CSF-060","phrase":"Could you walk me through...?"}]},{"speaker":"Friend","question":"Honestly, I barely got it either. Want to ask Mia?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-031","phrase":"Go ahead, you first."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-027', 'Hotel room is not ready', 'Travel & Hotel', 'It''s past the stated check-in time, but the receptionist says your room isn''t ready.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-027',
  'SCN-027',
  1,
  null,
  'It''s past the stated check-in time, but the receptionist says your room isn''t ready.',
  'Would you mind waiting another hour?',
  'Understanding → Need → Alternative',
  'Oh, that''s a bummer. I''ve been traveling all day and was really hoping to settle in. Is there another room, or could you hold my bags?',
  '{"id":"understanding-need-alternative","name":"Understanding → Need → Alternative","steps":[{"label":"Understanding","answer":"Oh, that''s a bummer."},{"label":"Need","answer":"I''ve been traveling all day and was really hoping to settle in."},{"label":"Alternative","answer":"Is there another room, or could you hold my bags?"}]}'::jsonb,
  '[{"speaker":"Receptionist","question":"There''s a smaller room ready now. Would you like to switch to it?","decks":[{"code":"CSF-061","phrase":"Does that include...?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Receptionist","question":"We can store your bags, but the room won''t be ready until five. Is that okay?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-054","phrase":"What other options do we have?"}]},{"speaker":"Receptionist","question":"I''m afraid there''s no room we can offer right now. Would you like to speak to a supervisor?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-055","phrase":"Could I speak to someone who can help with this?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-028', 'Missed a gate change', 'Travel & Hotel', 'You missed an airport announcement and can''t find the new boarding gate.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-028',
  'SCN-028',
  1,
  null,
  'You missed an airport announcement and can''t find the new boarding gate.',
  'Did you catch the new gate number?',
  'Admission → Context → Request',
  'Nope, I completely missed it. It was so noisy I couldn''t hear the announcement. Do you know which gate we''re at now?',
  '{"id":"admission-context-request","name":"Admission → Context → Request","steps":[{"label":"Admission","answer":"Nope, I completely missed it."},{"label":"Context","answer":"It was so noisy I couldn''t hear the announcement."},{"label":"Request","answer":"Do you know which gate we''re at now?"}]}'::jsonb,
  '[{"speaker":"Airport staff","question":"Your gate is B17, at the far end of the terminal. Got that?","decks":[{"code":"CSF-006","phrase":"Just to make sure I''ve got this right..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Airport staff","question":"I think it''s B17, but I''m not completely sure. Do you want me to check?","decks":[{"code":"CSF-062","phrase":"I don''t have that information yet."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Airport staff","question":"Boarding closes in five minutes. Do you know how to get there?","decks":[{"code":"CSF-060","phrase":"Could you walk me through...?"},{"code":"CSF-054","phrase":"What other options do we have?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-029', 'A flight connection is tight', 'Travel & Hotel', 'Your first flight is delayed and your connecting flight leaves soon.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-029',
  'SCN-029',
  1,
  null,
  'Your first flight is delayed and your connecting flight leaves soon.',
  'Do you have a connecting flight today?',
  'Answer → Concern → Request',
  'Yeah, and I''m cutting it pretty close. My next flight leaves in about an hour. Could you check whether I still have time to make it?',
  '{"id":"answer-concern-request","name":"Answer → Concern → Request","steps":[{"label":"Answer","answer":"Yeah, and I''m cutting it pretty close."},{"label":"Concern","answer":"My next flight leaves in about an hour."},{"label":"Request","answer":"Could you check whether I still have time to make it?"}]}'::jsonb,
  '[{"speaker":"Airline agent","question":"You might still make it if you go straight to gate C12. Any questions?","decks":[{"code":"CSF-006","phrase":"Just to make sure I''ve got this right..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Airline agent","question":"I''m afraid you won''t make that connection. Would you like us to rebook you?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Airline agent","question":"You''ll need to collect your bags and check in again. Do you know that process?","decks":[{"code":"CSF-003","phrase":"What do you mean by..."},{"code":"CSF-060","phrase":"Could you walk me through...?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-030', 'Asking for a quieter room', 'Travel & Hotel', 'Your hotel room faces a noisy street and you haven''t slept well.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-030',
  'SCN-030',
  1,
  null,
  'Your hotel room faces a noisy street and you haven''t slept well.',
  'How was your first night with us?',
  'Honest feedback → Cause → Request',
  'To be honest, I barely slept. The traffic outside was loud all night. Any chance I could move to a quieter room?',
  '{"id":"honest-feedback-cause-request","name":"Honest feedback → Cause → Request","steps":[{"label":"Honest feedback","answer":"To be honest, I barely slept."},{"label":"Cause","answer":"The traffic outside was loud all night."},{"label":"Request","answer":"Any chance I could move to a quieter room?"}]}'::jsonb,
  '[{"speaker":"Receptionist","question":"We have a quieter room upstairs, but it costs another twenty-five dollars. Interested?","decks":[{"code":"CSF-061","phrase":"Does that include...?"},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Receptionist","question":"I''m sorry, there isn''t a quieter room available tonight. Is there anything else we can do?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-055","phrase":"Could I speak to someone who can help with this?"}]},{"speaker":"Receptionist","question":"Could you tell me exactly what kept you awake?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-042","phrase":"I may not have explained that clearly."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-031', 'The taxi is going the wrong way', 'Travel & Hotel', 'You notice your taxi driver has taken a turn that sends you away from the hotel.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-031',
  'SCN-031',
  1,
  null,
  'You notice your taxi driver has taken a turn that sends you away from the hotel.',
  'Is this route okay?',
  'Soft concern → Evidence → Check',
  'Hey, I could be wrong, but I think we missed a turn. My map''s showing a different route. Could we double-check the hotel address?',
  '{"id":"soft-concern-evidence-check","name":"Soft concern → Evidence → Check","steps":[{"label":"Soft concern","answer":"Hey, I could be wrong, but I think we missed a turn."},{"label":"Evidence","answer":"My map''s showing a different route."},{"label":"Check","answer":"Could we double-check the hotel address?"}]}'::jsonb,
  '[{"speaker":"Driver","question":"This road avoids traffic. Do you still want me to follow your map?","decks":[{"code":"CSF-059","phrase":"I see your point, but..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Driver","question":"Which hotel are you going to again?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-008","phrase":"Could you spell that for me?"}]},{"speaker":"Driver","question":"Your route is closed. Should I take the toll highway instead?","decks":[{"code":"CSF-061","phrase":"Does that include...?"},{"code":"CSF-052","phrase":"Would it work if..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-032', 'You lost your luggage', 'Travel & Hotel', 'Your checked bag did not appear at the luggage carousel.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-032',
  'SCN-032',
  1,
  null,
  'Your checked bag did not appear at the luggage carousel.',
  'Has all your luggage arrived?',
  'Answer → Detail → Request',
  'No, I''m still missing one bag. I checked it in, but it never showed up on the carousel. Can you help me file a report?',
  '{"id":"answer-detail-request","name":"Answer → Detail → Request","steps":[{"label":"Answer","answer":"No, I''m still missing one bag."},{"label":"Detail","answer":"I checked it in, but it never showed up on the carousel."},{"label":"Request","answer":"Can you help me file a report?"}]}'::jsonb,
  '[{"speaker":"Baggage agent","question":"Do you have a photo of the missing suitcase?","decks":[{"code":"CSF-011","phrase":"Give me a moment to check."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Baggage agent","question":"We can deliver it tomorrow, but we need your address. Is that all right?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Baggage agent","question":"We still haven''t found your bag. Would you like a tracking reference?","decks":[{"code":"CSF-066","phrase":"Any update on...?"},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-033', 'A reservation cannot be found', 'Travel & Hotel', 'You arrive at a hotel with a booking confirmation, but staff can''t locate it.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-033',
  'SCN-033',
  1,
  null,
  'You arrive at a hotel with a booking confirmation, but staff can''t locate it.',
  'I''m sorry, I can''t find your reservation. Do you have a confirmation?',
  'Confirm → Evidence → Request',
  'Yep, I''ve got the confirmation right here. The booking should be under my name, and here''s the number. Could you try searching again?',
  '{"id":"confirm-evidence-request","name":"Confirm → Evidence → Request","steps":[{"label":"Confirm","answer":"Yep, I''ve got the confirmation right here."},{"label":"Evidence","answer":"The booking should be under my name, and here''s the number."},{"label":"Request","answer":"Could you try searching again?"}]}'::jsonb,
  '[{"speaker":"Receptionist","question":"Could the reservation be under someone else''s name?","decks":[{"code":"CSF-011","phrase":"Give me a moment to check."},{"code":"CSF-007","phrase":"Did you mean..."}]},{"speaker":"Receptionist","question":"I found it, but it says next month. Could the date be wrong?","decks":[{"code":"CSF-015","phrase":"Sorry, I meant..."},{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."}]},{"speaker":"Receptionist","question":"I''m sorry, we''re fully booked tonight. Would you like help finding another hotel?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-055","phrase":"Could I speak to someone who can help with this?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-034', 'Asking about public transport', 'Travel & Hotel', 'You need to reach the city center but are unsure which train to take.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-034',
  'SCN-034',
  1,
  null,
  'You need to reach the city center but are unsure which train to take.',
  'Where are you trying to get to?',
  'Destination → Uncertainty → Ask',
  'I''m trying to get downtown. It''s my first time taking the train here, so I''m a little lost. Which line should I hop on?',
  '{"id":"destination-uncertainty-ask","name":"Destination → Uncertainty → Ask","steps":[{"label":"Destination","answer":"I''m trying to get downtown."},{"label":"Uncertainty","answer":"It''s my first time taking the train here, so I''m a little lost."},{"label":"Ask","answer":"Which line should I hop on?"}]}'::jsonb,
  '[{"speaker":"Station staff","question":"Take the green line and change at Central Square. Does that make sense?","decks":[{"code":"CSF-006","phrase":"Just to make sure I''ve got this right..."},{"code":"CSF-008","phrase":"Could you spell that for me?"}]},{"speaker":"Station staff","question":"The green line is delayed today. Would you like another route?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-060","phrase":"Could you walk me through...?"}]},{"speaker":"Station staff","question":"Are you going to the downtown train station or the bus terminal?","decks":[{"code":"CSF-007","phrase":"Did you mean..."},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-035', 'A package says delivered but is missing', 'Daily Life & Service', 'A delivery tracking page says delivered, but there is no parcel at your door.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-035',
  'SCN-035',
  1,
  null,
  'A delivery tracking page says delivered, but there is no parcel at your door.',
  'I can see it was delivered. Have you checked outside?',
  'Correction → Already checked → Request',
  'Yeah, I''ve checked everywhere I can think of. It''s not outside my door or in the lobby. Could you find out where the driver left it?',
  '{"id":"correction-already-checked-request","name":"Correction → Already checked → Request","steps":[{"label":"Correction","answer":"Yeah, I''ve checked everywhere I can think of."},{"label":"Already checked","answer":"It''s not outside my door or in the lobby."},{"label":"Request","answer":"Could you find out where the driver left it?"}]}'::jsonb,
  '[{"speaker":"Support agent","question":"Have you checked with the neighbors too?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-066","phrase":"Any update on...?"}]},{"speaker":"Support agent","question":"The driver says it was left at the side gate. Have you looked there?","decks":[{"code":"CSF-043","phrase":"We might be talking about two different things."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Support agent","question":"We can''t open an investigation until tomorrow. Is that okay with you?","decks":[{"code":"CSF-055","phrase":"Could I speak to someone who can help with this?"},{"code":"CSF-066","phrase":"Any update on...?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-036', 'Returning a defective product', 'Daily Life & Service', 'You bought headphones yesterday, but one side doesn''t work.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-036',
  'SCN-036',
  1,
  null,
  'You bought headphones yesterday, but one side doesn''t work.',
  'Is there a problem with the headphones?',
  'Problem → Timing → Resolution',
  'Yeah, the left earbud''s not working. I literally bought these yesterday. Could I exchange them for another pair?',
  '{"id":"problem-timing-resolution","name":"Problem → Timing → Resolution","steps":[{"label":"Problem","answer":"Yeah, the left earbud''s not working."},{"label":"Timing","answer":"I literally bought these yesterday."},{"label":"Resolution","answer":"Could I exchange them for another pair?"}]}'::jsonb,
  '[{"speaker":"Store clerk","question":"We can exchange them if you have the receipt. Do you still have it?","decks":[{"code":"CSF-011","phrase":"Give me a moment to check."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Store clerk","question":"We don''t have that headphone model in stock. Would you consider another one?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Store clerk","question":"The policy says this isn''t covered. Would you like me to explain why?","decks":[{"code":"CSF-059","phrase":"I see your point, but..."},{"code":"CSF-055","phrase":"Could I speak to someone who can help with this?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-037', 'A subscription renewed unexpectedly', 'Daily Life & Service', 'You notice a charge from an app you thought you had canceled.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-037',
  'SCN-037',
  1,
  null,
  'You notice a charge from an app you thought you had canceled.',
  'How can I help with your subscription?',
  'Issue → Context → Request',
  'I think something went wrong with my subscription. I thought I''d canceled it, but I got charged again. Could you check that and see if I can get a refund?',
  '{"id":"issue-context-request","name":"Issue → Context → Request","steps":[{"label":"Issue","answer":"I think something went wrong with my subscription."},{"label":"Context","answer":"I thought I''d canceled it, but I got charged again."},{"label":"Request","answer":"Could you check that and see if I can get a refund?"}]}'::jsonb,
  '[{"speaker":"Support agent","question":"Our system says you canceled after the renewal date. Could that be right?","decks":[{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."},{"code":"CSF-060","phrase":"Could you walk me through...?"}]},{"speaker":"Support agent","question":"We can offer store credit, but not a cash refund. Would you accept that?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Support agent","question":"Should I cancel the subscription now so it won''t renew again?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-061","phrase":"Does that include...?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-038', 'A neighbor is being too loud', 'Daily Life & Service', 'It''s late at night and your neighbor''s music is keeping you awake.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-038',
  'SCN-038',
  1,
  null,
  'It''s late at night and your neighbor''s music is keeping you awake.',
  'Oh, is the music bothering you?',
  'Confirm → Impact → Request',
  'Yeah, a little, to be honest. I''m trying to sleep, and the music''s coming through the wall. Could you turn it down a bit?',
  '{"id":"confirm-impact-request","name":"Confirm → Impact → Request","steps":[{"label":"Confirm","answer":"Yeah, a little, to be honest."},{"label":"Impact","answer":"I''m trying to sleep, and the music''s coming through the wall."},{"label":"Request","answer":"Could you turn it down a bit?"}]}'::jsonb,
  '[{"speaker":"Neighbor","question":"Sorry about that. Is the volume better now?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-047","phrase":"I''ll let you get back to it."}]},{"speaker":"Neighbor","question":"We''re having friends over. Could we keep the music on for one more hour?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Neighbor","question":"Actually, the music is coming from upstairs. Did you mean that apartment?","decks":[{"code":"CSF-015","phrase":"Sorry, I meant..."},{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-039', 'The repair person is hours late', 'Daily Life & Service', 'You took the morning off work for a technician who still has not shown up by lunchtime.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-039',
  'SCN-039',
  1,
  null,
  'You took the morning off work for a technician who still has not shown up by lunchtime.',
  'Hi, are you calling about your appointment?',
  'Confirm → Problem → ETA request',
  'Yeah, I''ve been waiting all morning. I even took time off work for this. Do you have an updated arrival time?',
  '{"id":"confirm-problem-eta-request","name":"Confirm → Problem → ETA request","steps":[{"label":"Confirm","answer":"Yeah, I''ve been waiting all morning."},{"label":"Problem","answer":"I even took time off work for this."},{"label":"ETA request","answer":"Do you have an updated arrival time?"}]}'::jsonb,
  '[{"speaker":"Support agent","question":"The technician is two hours late. Can you still wait today?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Support agent","question":"We don''t have an exact arrival time. Do you want to keep waiting?","decks":[{"code":"CSF-066","phrase":"Any update on...?"},{"code":"CSF-054","phrase":"What other options do we have?"}]},{"speaker":"Support agent","question":"Can we move the appointment to tomorrow morning instead?","decks":[{"code":"CSF-010","phrase":"Can I get back to you on that?"},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-040', 'Asking to exchange clothing size', 'Daily Life & Service', 'You bought a jacket that is too small, and you still have the receipt.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-040',
  'SCN-040',
  1,
  null,
  'You bought a jacket that is too small, and you still have the receipt.',
  'How can I help you today?',
  'Issue → Evidence → Request',
  'Hey, this jacket''s a little too tight on me. I just bought it yesterday, and I''ve still got the receipt. Could I swap it for a size up?',
  '{"id":"issue-evidence-request","name":"Issue → Evidence → Request","steps":[{"label":"Issue","answer":"Hey, this jacket''s a little too tight on me."},{"label":"Evidence","answer":"I just bought it yesterday, and I''ve still got the receipt."},{"label":"Request","answer":"Could I swap it for a size up?"}]}'::jsonb,
  '[{"speaker":"Store clerk","question":"We have one size larger, but only in black. Would that work?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Store clerk","question":"Have you worn the jacket outside at all?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Store clerk","question":"You removed the original tag, so I can''t exchange it. What would you like me to do?","decks":[{"code":"CSF-054","phrase":"What other options do we have?"},{"code":"CSF-059","phrase":"I see your point, but..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-041', 'Someone cuts right in front of you', 'Daily Life & Service', 'You have been waiting in line for coffee, and someone steps directly in front of you.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-041',
  'SCN-041',
  1,
  null,
  'You have been waiting in line for coffee, and someone steps directly in front of you.',
  'Oh, were you waiting here?',
  'Confirm → Position → Direction',
  'Yeah, I''ve been waiting here a while. No worries, it''s an easy mistake. The line actually starts back there.',
  '{"id":"confirm-position-direction","name":"Confirm → Position → Direction","steps":[{"label":"Confirm","answer":"Yeah, I''ve been waiting here a while."},{"label":"Position","answer":"No worries, it''s an easy mistake."},{"label":"Direction","answer":"The line actually starts back there."}]}'::jsonb,
  '[{"speaker":"Stranger","question":"Oh, I didn''t notice. The line starts back there, right?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-047","phrase":"I''ll let you get back to it."}]},{"speaker":"Stranger","question":"I''m only buying one coffee. Could I go ahead of you?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Stranger","question":"Someone told me to stand here. Are you sure this isn''t the line?","decks":[{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."},{"code":"CSF-056","phrase":"Just to confirm..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-042', 'Wrong item on a receipt', 'Daily Life & Service', 'You notice a product you didn''t buy on your supermarket receipt.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-042',
  'SCN-042',
  1,
  null,
  'You notice a product you didn''t buy on your supermarket receipt.',
  'Is everything alright with your receipt?',
  'Issue → Evidence → Request',
  'I think I got charged for something I didn''t buy. This item right here isn''t mine. Could you take a look?',
  '{"id":"issue-evidence-request","name":"Issue → Evidence → Request","steps":[{"label":"Issue","answer":"I think I got charged for something I didn''t buy."},{"label":"Evidence","answer":"This item right here isn''t mine."},{"label":"Request","answer":"Could you take a look?"}]}'::jsonb,
  '[{"speaker":"Cashier","question":"Is this bottle of water the item you mean?","decks":[{"code":"CSF-007","phrase":"Did you mean..."},{"code":"CSF-056","phrase":"Just to confirm..."}]},{"speaker":"Cashier","question":"Our register shows you bought two. Could one be in your bag?","decks":[{"code":"CSF-040","phrase":"I think there''s been a misunderstanding."},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Cashier","question":"I can remove the charge, but the refund may take three days. Is that okay?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-061","phrase":"Does that include...?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-043', 'Explaining an employment gap', 'Job Interview', 'You took several months off to care for a family member and are interviewing again.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-043',
  'SCN-043',
  1,
  null,
  'You took several months off to care for a family member and are interviewing again.',
  'Can you tell me about this gap in your employment?',
  'Reason → Present situation → Readiness',
  'I took some time off to take care of someone in my family. Things are a lot more settled now, thankfully. I''m ready to get back to work.',
  '{"id":"reason-present-situation-readiness","name":"Reason → Present situation → Readiness","steps":[{"label":"Reason","answer":"I took some time off to take care of someone in my family."},{"label":"Present situation","answer":"Things are a lot more settled now, thankfully."},{"label":"Readiness","answer":"I''m ready to get back to work."}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"Are you fully available to return to work now?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]},{"speaker":"Interviewer","question":"How did you keep your professional skills up during that time?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-012","phrase":"Off the top of my head..."}]},{"speaker":"Interviewer","question":"Would you mind saying which family member you were caring for?","decks":[{"code":"CSF-063","phrase":"I''d rather keep that private."},{"code":"CSF-053","phrase":"I''m afraid I can''t..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-044', 'Not knowing a technical tool', 'Job Interview', 'The interviewer asks whether you''ve used a tool you haven''t worked with.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-044',
  'SCN-044',
  1,
  null,
  'The interviewer asks whether you''ve used a tool you haven''t worked with.',
  'Have you used Salesforce before?',
  'Honest answer → Transferable experience → Confidence',
  'Not yet, actually—I haven''t used Salesforce. I have worked with other CRM tools, though. I''m pretty confident I can pick it up quickly.',
  '{"id":"honest-answer-transferable-experience-confidence","name":"Honest answer → Transferable experience → Confidence","steps":[{"label":"Honest answer","answer":"Not yet, actually—I haven''t used Salesforce."},{"label":"Transferable experience","answer":"I have worked with other CRM tools, though."},{"label":"Confidence","answer":"I''m pretty confident I can pick it up quickly."}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"Which other CRM tools have you worked with?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-012","phrase":"Off the top of my head..."}]},{"speaker":"Interviewer","question":"We need someone who can use Salesforce from day one. How would you handle that?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Interviewer","question":"So would you say you''re already a Salesforce expert?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-062","phrase":"I don''t have that information yet."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-045', 'Discussing expected salary', 'Job Interview', 'The interviewer asks for your salary expectations before giving a salary range.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-045',
  'SCN-045',
  1,
  null,
  'The interviewer asks for your salary expectations before giving a salary range.',
  'What salary are you looking for?',
  'Position → Reason → Question',
  'I''m pretty flexible, depending on the role. I''d like to get a better sense of the responsibilities and benefits first. Could you share the range you have in mind?',
  '{"id":"position-reason-question","name":"Position → Reason → Question","steps":[{"label":"Position","answer":"I''m pretty flexible, depending on the role."},{"label":"Reason","answer":"I''d like to get a better sense of the responsibilities and benefits first."},{"label":"Question","answer":"Could you share the range you have in mind?"}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"Our budget is fifteen hundred dollars per month. Would that work for you?","decks":[{"code":"CSF-052","phrase":"Would it work if..."},{"code":"CSF-064","phrase":"Could we meet halfway?"}]},{"speaker":"Interviewer","question":"We can''t share our range yet. Could you give us your minimum?","decks":[{"code":"CSF-009","phrase":"Let me think for a second."},{"code":"CSF-061","phrase":"Does that include...?"}]},{"speaker":"Interviewer","question":"Are you saying salary matters more to you than the work itself?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-016","phrase":"What I''m trying to say is..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-046', 'A difficult weakness question', 'Job Interview', 'An interviewer asks about a weakness you are currently working on.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-046',
  'SCN-046',
  1,
  null,
  'An interviewer asks about a weakness you are currently working on.',
  'What''s one weakness you''re working on?',
  'Weakness → Improvement → Evidence',
  'One thing I''ve been working on is slowing down at the end of a project. I used to rush the final checks, so now I use a checklist. It''s helped me catch little mistakes before they go out.',
  '{"id":"weakness-improvement-evidence","name":"Weakness → Improvement → Evidence","steps":[{"label":"Weakness","answer":"One thing I''ve been working on is slowing down at the end of a project."},{"label":"Improvement","answer":"I used to rush the final checks, so now I use a checklist."},{"label":"Evidence","answer":"It''s helped me catch little mistakes before they go out."}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"Can you give me a recent example of something your checklist caught?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-012","phrase":"Off the top of my head..."}]},{"speaker":"Interviewer","question":"Does that mean you still struggle to meet deadlines?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-017","phrase":"Let me put it another way."}]},{"speaker":"Interviewer","question":"What if you had only five minutes left to check something important?","decks":[{"code":"CSF-058","phrase":"Here''s what I can do."},{"code":"CSF-051","phrase":"If this has to come first, what should I put on hold?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-047', 'The interviewer asks a question you did not expect', 'Job Interview', 'During an interview, you get an unexpected question about a conflict with a coworker. You need a moment to think.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-047',
  'SCN-047',
  1,
  null,
  'During an interview, you get an unexpected question about a conflict with a coworker. You need a moment to think.',
  'Can you tell me about a time you disagreed with a coworker?',
  'Acknowledge → Pause → Commitment',
  'That''s a good one. Let me think about that for a second. I want to pick a real example, not just make something up.',
  '{"id":"acknowledge-pause-commitment","name":"Acknowledge → Pause → Commitment","steps":[{"label":"Acknowledge","answer":"That''s a good one."},{"label":"Pause","answer":"Let me think about that for a second."},{"label":"Commitment","answer":"I want to pick a real example, not just make something up."}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"Take your time. Which disagreement comes to mind first?","decks":[{"code":"CSF-009","phrase":"Let me think for a second."},{"code":"CSF-065","phrase":"For example..."}]},{"speaker":"Interviewer","question":"What exactly were you and your coworker disagreeing about?","decks":[{"code":"CSF-016","phrase":"What I''m trying to say is..."},{"code":"CSF-065","phrase":"For example..."}]},{"speaker":"Interviewer","question":"What did you do when they refused to compromise?","decks":[{"code":"CSF-059","phrase":"I see your point, but..."},{"code":"CSF-064","phrase":"Could we meet halfway?"}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-048', 'Asking about remote work', 'Job Interview', 'You are interested in a job and want to know whether hybrid work is available.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-048',
  'SCN-048',
  1,
  null,
  'You are interested in a job and want to know whether hybrid work is available.',
  'Do you have any questions about the role?',
  'Open → Specific interest → Question',
  'Yeah, actually, I have one question. I saw that the team sometimes works from home. What''s the usual split between home and office days?',
  '{"id":"open-specific-interest-question","name":"Open → Specific interest → Question","steps":[{"label":"Open","answer":"Yeah, actually, I have one question."},{"label":"Specific interest","answer":"I saw that the team sometimes works from home."},{"label":"Question","answer":"What''s the usual split between home and office days?"}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"We come to the office three days a week. Does that work for you?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-052","phrase":"Would it work if..."}]},{"speaker":"Interviewer","question":"Would fully on-site work be a deal-breaker for you?","decks":[{"code":"CSF-053","phrase":"I''m afraid I can''t..."},{"code":"CSF-059","phrase":"I see your point, but..."}]},{"speaker":"Interviewer","question":"Why does working from home matter to you?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-016","phrase":"What I''m trying to say is..."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-049', 'Explaining why you left', 'Job Interview', 'You left your last role because there were limited opportunities to grow.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-049',
  'SCN-049',
  1,
  null,
  'You left your last role because there were limited opportunities to grow.',
  'Why did you leave your previous job?',
  'Appreciation → Reason → Future',
  'I learned a lot at my last job, for sure. After a while, though, I felt like I''d hit a ceiling. I''m looking for a role where I can keep growing.',
  '{"id":"appreciation-reason-future","name":"Appreciation → Reason → Future","steps":[{"label":"Appreciation","answer":"I learned a lot at my last job, for sure."},{"label":"Reason","answer":"After a while, though, I felt like I''d hit a ceiling."},{"label":"Future","answer":"I''m looking for a role where I can keep growing."}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"What made you feel you''d hit a ceiling in your last role?","decks":[{"code":"CSF-065","phrase":"For example..."},{"code":"CSF-012","phrase":"Off the top of my head..."}]},{"speaker":"Interviewer","question":"So was the real problem that you didn''t get along with your manager?","decks":[{"code":"CSF-041","phrase":"That''s not quite what I meant."},{"code":"CSF-016","phrase":"What I''m trying to say is..."}]},{"speaker":"Interviewer","question":"What kind of growth would you like to have here?","decks":[{"code":"CSF-016","phrase":"What I''m trying to say is..."},{"code":"CSF-058","phrase":"Here''s what I can do."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


insert into public.episodes (id, title, topic, description, language, status, published_at)
values ('SCN-050', 'Asking about next steps', 'Job Interview', 'The interview is ending, and you want to know what happens next.', 'en-US', 'published', now())
on conflict (id) do update set
  title = excluded.title,
  topic = excluded.topic,
  description = excluded.description,
  language = excluded.language,
  status = excluded.status,
  published_at = coalesce(public.episodes.published_at, excluded.published_at),
  updated_at = now();

insert into public.cards (
  id, episode_id, sort_order, level, context, question, task, answer, framework, follow_ups, content_version
) values (
  'SCN-050',
  'SCN-050',
  1,
  null,
  'The interview is ending, and you want to know what happens next.',
  'Is there anything else you''d like to ask?',
  'Interest → Focus → Question',
  'Yeah, just one quick thing. I''m really interested in the role and would love to know what happens next. When do you think you''ll make a decision?',
  '{"id":"interest-focus-question","name":"Interest → Focus → Question","steps":[{"label":"Interest","answer":"Yeah, just one quick thing."},{"label":"Focus","answer":"I''m really interested in the role and would love to know what happens next."},{"label":"Question","answer":"When do you think you''ll make a decision?"}]}'::jsonb,
  '[{"speaker":"Interviewer","question":"We''re aiming to decide in two weeks. Does that timeline work for you?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-010","phrase":"Can I get back to you on that?"}]},{"speaker":"Interviewer","question":"The schedule could still change. Would you be okay with an update by email?","decks":[{"code":"CSF-056","phrase":"Just to confirm..."},{"code":"CSF-066","phrase":"Any update on...?"}]},{"speaker":"Interviewer","question":"Anything else you need before we wrap up?","decks":[{"code":"CSF-037","phrase":"Before I forget..."},{"code":"CSF-049","phrase":"I won''t keep you any longer."}]}]'::jsonb,
  1
)
on conflict (id) do update set
  episode_id = excluded.episode_id,
  sort_order = excluded.sort_order,
  level = excluded.level,
  context = excluded.context,
  question = excluded.question,
  task = excluded.task,
  answer = excluded.answer,
  framework = excluded.framework,
  follow_ups = excluded.follow_ups,
  content_version = excluded.content_version,
  updated_at = now();


commit;
