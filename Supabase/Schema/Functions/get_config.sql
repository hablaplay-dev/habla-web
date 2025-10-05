CREATE OR REPLACE FUNCTION public.get_config(p_key text)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select value from public.app_config where key = p_key
$function$
