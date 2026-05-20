-- Run this in Supabase SQL Editor

-- Kambariai (game rooms)
create table if not exists rooms (
  id text primary key,
  secret_word text not null,
  secret_category text not null default 'daiktas',
  secret_image_url text,
  host_id text not null,
  status text not null default 'waiting', -- waiting, playing, guessed, finished
  questions_left int not null default 20,
  current_questioner text,
  created_at timestamptz default now()
);

-- Žaidėjai
create table if not exists players (
  id text primary key,
  room_id text references rooms(id) on delete cascade,
  name text not null,
  is_host boolean default false,
  joined_at timestamptz default now()
);

-- Klausimai ir atsakymai
create table if not exists questions (
  id uuid primary key default gen_random_uuid(),
  room_id text references rooms(id) on delete cascade,
  player_id text,
  player_name text not null,
  question text not null,
  answer text, -- 'taip', 'ne', 'gali_buti', 'yra'
  created_at timestamptz default now()
);

-- Enable realtime
alter publication supabase_realtime add table rooms;
alter publication supabase_realtime add table players;
alter publication supabase_realtime add table questions;

-- RLS policies (allow all for simplicity - can tighten later)
alter table rooms enable row level security;
alter table players enable row level security;
alter table questions enable row level security;

create policy "Allow all rooms" on rooms for all using (true) with check (true);
create policy "Allow all players" on players for all using (true) with check (true);
create policy "Allow all questions" on questions for all using (true) with check (true);
