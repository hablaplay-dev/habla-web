-- ============================================
-- Extensiones
-- ============================================
create extension if not exists pg_net  with schema extensions;
create extension if not exists pg_cron with schema cron;

-- ============================================
-- Tabla de configuración
-- ============================================
create table if not exists public.app_config (
  key   text primary key,
  value text not null
);

-- Insertar valores (modifica en entorno real con tus secretos)
insert into public.app_config(key, value) values
  ('edge_bearer', 'ANON_KEY_AQUI'),
  ('scheduler_secret', 'SchedulerSecretAqui')
on conflict (key) do update set value = excluded.value;

-- ============================================
-- Helper para leer config
-- ============================================
create or replace function public.get_config(p_key text)
returns text
language sql
stable
as $$
  select value from public.app_config where key = p_key
$$;

-- ============================================
-- call_edge: hace POST con Authorization
-- ============================================
create or replace function public.call_edge(
  text_endpoint text,
  text_payload  jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_url       text := 'https://TU-PROJECT-REF.functions.supabase.co' || text_endpoint;
  v_secret    text := public.get_config('scheduler_secret');
  v_bearer    text := public.get_config('edge_bearer');
  v_auth      text;
begin
  v_auth := 'Bearer ' || coalesce(v_bearer, '');
  perform net.http_post(
    url     := v_url,
    headers := jsonb_build_object(
                 'Content-Type','application/json',
                 'Authorization', v_auth,
                 'X-Habla-Scheduler', coalesce(v_secret,'dev')
               ),
    body    := coalesce(text_payload,'{}'::jsonb)
  );
end
$$;

-- ============================================
-- Jobs CRON
-- ============================================

-- LIVE: cada 2 minutos
select cron.schedule(
  job_name   => 'habla-sync-live',
  schedule   => '*/2 * * * *',
  command    => $$select public.call_edge('/api-football/sync-live', '{}'::jsonb);$$
);

-- PRE: cada 15 minutos con fecha actual (UTC)
select cron.schedule(
  job_name   => 'habla-sync-pre',
  schedule   => '*/15 * * * *',
  command    => $$
    select public.call_edge(
      '/api-football/seed-fixtures?date=' ||
      to_char(now() at time zone 'UTC','YYYY-MM-DD')
    );
  $$
);

-- POST: dos veces por hora
select cron.schedule(
  job_name   => 'habla-sync-post',
  schedule   => '5,35 * * * *',
  command    => $$select public.call_edge('/api-football/sync-live', '{}'::jsonb);$$
);
