CREATE OR REPLACE FUNCTION public.get_user_ticket(p_match_id bigint)
 RETURNS TABLE(ticket_id bigint, status text, submitted_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select t.id, t.status, t.submitted_at
  from tickets t
  where t.user_id = auth.uid()
    and t.match_id = p_match_id
  order by t.submitted_at desc nulls last, t.id desc
$function$
