-- ============================================
-- Extensiones necesarias
-- ============================================
create extension if not exists pg_net  with schema extensions;
create extension if not exists pg_cron with schema cron;

-- ============================================
-- app_config table
-- ============================================
create table if not exists public.app_config (
  key   text primary key,
  value text not null
);

-- Helper get_config
create or replace function public.get_config(p_key text)
returns text
language sql
stable
as $$
  select value from public.app_config where key = p_key
$$;

-- call_edge function
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
  v_url       text := 'https://ajogsubrgcsgrtieqffh.functions.supabase.co' || text_endpoint;
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
