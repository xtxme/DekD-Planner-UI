create extension if not exists pgcrypto;
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  bio text not null default '',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_notification_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  all_notifications_enabled boolean not null default true,
  reminder_preset text not null default 'one_day_before'
    check (reminder_preset in ('one_day_before', 'six_hours_before', 'custom')),
  reminder_amount integer not null default 1
    check (reminder_amount between 1 and 7),
  reminder_unit text not null default 'days_before'
    check (reminder_unit in ('hours_before', 'days_before', 'weeks_before')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  code text not null,
  description text not null default '',
  color_value integer not null default 0,
  icon_codepoint integer not null default 0,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint subjects_user_id_code_key unique (user_id, code)
);
alter table public.assignments
  add column if not exists subject_id uuid references public.subjects(id) on delete restrict,
  add column if not exists status text not null default 'in_progress'
    check (status in ('to_do', 'in_progress', 'late', 'completed')),
  add column if not exists completed_at timestamptz;

create index if not exists idx_home_tasks_user_due_at on public.home_tasks(user_id, due_at);
create index if not exists idx_assignments_user_due_at on public.assignments(user_id, due_at);
create index if not exists idx_assignments_user_subject_id on public.assignments(user_id, subject_id);
create index if not exists idx_assignments_user_status on public.assignments(user_id, status);
create index if not exists idx_subjects_user_id on public.subjects(user_id);

alter table public.profiles enable row level security;
alter table public.user_notification_preferences enable row level security;
alter table public.subjects enable row level security;
alter table public.assignments enable row level security;
alter table public.home_tasks enable row level security;

create policy "profiles_select_own" on public.profiles
for select using (auth.uid() = user_id);
create policy "profiles_insert_own" on public.profiles
for insert with check (auth.uid() = user_id);
create policy "profiles_update_own" on public.profiles
for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "profiles_delete_own" on public.profiles
for delete using (auth.uid() = user_id);

create policy "user_notification_preferences_select_own" on public.user_notification_preferences
for select using (auth.uid() = user_id);
create policy "user_notification_preferences_insert_own" on public.user_notification_preferences
for insert with check (auth.uid() = user_id);
create policy "user_notification_preferences_update_own" on public.user_notification_preferences
for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user_notification_preferences_delete_own" on public.user_notification_preferences
for delete using (auth.uid() = user_id);

create policy "subjects_select_own" on public.subjects
for select using (auth.uid() = user_id);
create policy "subjects_insert_own" on public.subjects
for insert with check (auth.uid() = user_id);
create policy "subjects_update_own" on public.subjects
for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "subjects_delete_own" on public.subjects
for delete using (auth.uid() = user_id);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists user_notification_preferences_set_updated_at on public.user_notification_preferences;
create trigger user_notification_preferences_set_updated_at
before update on public.user_notification_preferences
for each row execute function public.set_updated_at();

drop trigger if exists subjects_set_updated_at on public.subjects;
create trigger subjects_set_updated_at
before update on public.subjects
for each row execute function public.set_updated_at();

drop trigger if exists assignments_set_updated_at on public.assignments;
create trigger assignments_set_updated_at
before update on public.assignments
for each row execute function public.set_updated_at();
