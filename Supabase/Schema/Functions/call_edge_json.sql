CREATE OR REPLACE FUNCTION public.call_edge_json(text_endpoint text, text_payload jsonb DEFAULT '{}'::jsonb)
 RETURNS TABLE(status integer, headers jsonb, body jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_url    text := 'https://ajogsubrgcsgrtieqffh.functions.supabase.co' || text_endpoint;
  v_secret text := public.get_config('scheduler_secret');
  v_bearer text := public.get_config('edge_bearer');
  v_req_id bigint;
  v_resp   record;
begin
  v_req_id := net.http_post(
    url     => v_url,
    headers => jsonb_build_object(
      'Content-Type','application/json',
      'Authorization', 'Bearer ' || coalesce(v_bearer,''),
      'X-Habla-Scheduler', coalesce(v_secret,'dev')
    ),
    body    => coalesce(text_payload,'{}'::jsonb)
  );

  select * into v_resp from net.http_collect(v_req_id);
  status  := v_resp.status;
  headers := v_resp.headers;
  body    := v_resp.body;
  return next;
end
$function$
