-- Deutsch Learning cloud sync. Run once in Supabase > SQL Editor > project-os.
-- Does NOT change the existing deutsch_learning_state table or other project tables.
create table if not exists public.deutsch_study_sync (
  user_id uuid not null references auth.users(id) on delete cascade,
  scope text not null,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id,scope),
  constraint deutsch_study_sync_scope_length check (char_length(scope) between 1 and 120)
);
alter table public.deutsch_study_sync enable row level security;
revoke all on public.deutsch_study_sync from anon;
grant select, insert, update, delete on public.deutsch_study_sync to authenticated;
drop policy if exists "deutsch_sync_select_own" on public.deutsch_study_sync;
drop policy if exists "deutsch_sync_insert_own" on public.deutsch_study_sync;
drop policy if exists "deutsch_sync_update_own" on public.deutsch_study_sync;
drop policy if exists "deutsch_sync_delete_own" on public.deutsch_study_sync;
create policy "deutsch_sync_select_own" on public.deutsch_study_sync for select to authenticated using ((select auth.uid()) = user_id);
create policy "deutsch_sync_insert_own" on public.deutsch_study_sync for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "deutsch_sync_update_own" on public.deutsch_study_sync for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "deutsch_sync_delete_own" on public.deutsch_study_sync for delete to authenticated using ((select auth.uid()) = user_id);
create index if not exists deutsch_study_sync_updated_idx on public.deutsch_study_sync(user_id,updated_at desc);
-- After running, confirm the table has RLS enabled and these four policies.
