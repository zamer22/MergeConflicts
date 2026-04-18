-- Agregar campos a rallies
alter table rallies
  add column if not exists category text default 'otro',
  add column if not exists tags text[] default '{}',
  add column if not exists image_url text;

-- Agregar campos a users
alter table users
  add column if not exists bio text,
  add column if not exists interests text[] default '{}',
  add column if not exists followers_count integer default 0,
  add column if not exists following_count integer default 0,
  add column if not exists location_label text;

-- Reviews
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  rally_id uuid references rallies(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  stars integer not null check (stars between 1 and 5),
  text text,
  created_at timestamp default now(),
  unique(rally_id, user_id)
);

-- Eventos guardados
create table if not exists saved_events (
  id uuid primary key default gen_random_uuid(),
  rally_id uuid references rallies(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  saved_at timestamp default now(),
  unique(rally_id, user_id)
);

-- Seguidores
create table if not exists follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid references users(id) on delete cascade,
  following_id uuid references users(id) on delete cascade,
  created_at timestamp default now(),
  unique(follower_id, following_id)
);

-- RLS para tablas nuevas
alter table reviews enable row level security;
alter table saved_events enable row level security;
alter table follows enable row level security;

create policy "Anyone can read reviews" on reviews for select using (true);
create policy "Users can write own review" on reviews for insert with check (auth.uid() = user_id);

create policy "Users can read own saved" on saved_events for select using (auth.uid() = user_id);
create policy "Users can save events" on saved_events for insert with check (auth.uid() = user_id);
create policy "Users can unsave events" on saved_events for delete using (auth.uid() = user_id);

create policy "Anyone can read follows" on follows for select using (true);
create policy "Users can follow" on follows for insert with check (auth.uid() = follower_id);
create policy "Users can unfollow" on follows for delete using (auth.uid() = follower_id);

-- Actualizar seed data con categorías y tags
update rallies set
  category = 'bar',
  tags = array['shots', 'pool', 'barrioantiguo']
where title = 'Shots y pool en El Catrin';

update rallies set
  category = 'bar',
  tags = array['rooftop', 'cervezas', 'vistas']
where title = 'Rooftop en Pangea';

update rallies set
  category = 'bar',
  tags = array['pre', 'antro', 'sanpedro']
where title = 'Pre en Baja antes del antro';

update rallies set
  category = 'gym',
  tags = array['entreno', 'funcional', 'tacos']
where title = 'Entreno grupal + tacos después';
