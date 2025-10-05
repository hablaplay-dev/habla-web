CREATE OR REPLACE FUNCTION public.call_edge(text_endpoint text, text_payload jsonb DEFAULT '{}'::jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  -- Cambia el subdominio por el de TU proyecto si no coincide
  v_url       text := 'https://ajogsubrgcsgrtieqffh.functions.supabase.co' || text_endpoint;
  v_secret    text := public.get_config('scheduler_secret');  -- desde app_config
  v_bearer    text := public.get_config('edge_bearer');       -- anon/service key
  v_auth      text;
begin
  if coalesce(v_bearer, '') = '' then
    raise notice '[call_edge] edge_bearer vacío; guarda tu ANON (o SERVICE) key en app_config.';
  end if;

  v_auth := 'Bearer ' || coalesce(v_bearer, '');

  -- ¡OJO! La función es net.http_post (schema "net")
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
$function$
