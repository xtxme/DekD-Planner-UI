-- Enable extension for UUID generation
create extension if not exists pgcrypto;

create table if not exists public.home_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject text not null,
  title text not null,
  subtitle text not null,
  due_at timestamptz not null,
  tag_bg integer not null,
  tag_color integer not null,
  due_bg integer not null,
  due_color integer not null,
  show_due_pill boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  subject text not null,
  due_at timestamptz not null,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists assignments_set_updated_at on public.assignments;
create trigger assignments_set_updated_at
before update on public.assignments
for each row
execute function public.set_updated_at();

alter table public.home_tasks enable row level security;
alter table public.assignments enable row level security;

create policy "home_tasks_select_own" on public.home_tasks
for select using (auth.uid() = user_id);

create policy "home_tasks_insert_own" on public.home_tasks
for insert with check (auth.uid() = user_id);

create policy "home_tasks_update_own" on public.home_tasks
for update using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "home_tasks_delete_own" on public.home_tasks
for delete using (auth.uid() = user_id);

create policy "assignments_select_own" on public.assignments
for select using (auth.uid() = user_id);

create policy "assignments_insert_own" on public.assignments
for insert with check (auth.uid() = user_id);

create policy "assignments_update_own" on public.assignments
for update using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "assignments_delete_own" on public.assignments
for delete using (auth.uid() = user_id);
