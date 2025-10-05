CREATE OR REPLACE FUNCTION public.submit_ticket(p_match_id bigint, p_s1 text, p_s2 text, p_s3 text, p_s4 text, p_s5 text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid;
  v_ticket_id bigint;
  v_locked boolean;
begin
  v_user := auth.uid();
  if v_user is null then
    raise exception 'Not authenticated';
  end if;

  -- Hard lock en DB
  select now() >= m.lock_time into v_locked
  from matches m
  where m.id = p_match_id
  limit 1;

  if coalesce(v_locked, true) then
    raise exception 'Match is locked for new tickets';
  end if;

  insert into tickets(user_id, match_id, status, submitted_at)
  values (v_user, p_match_id, 'SUBMITTED', now())
  on conflict (user_id, match_id) do update
    set submitted_at = excluded.submitted_at,
        status       = 'SUBMITTED'
  returning id into v_ticket_id;

  delete from ticket_answers where ticket_id = v_ticket_id;

  insert into ticket_answers(ticket_id, q_key, value) values
    (v_ticket_id, 's1', coalesce(p_s1,'-')),
    (v_ticket_id, 's2', coalesce(p_s2,'-')),
    (v_ticket_id, 's3', coalesce(p_s3,'-')),
    (v_ticket_id, 's4', coalesce(p_s4,'-')),
    (v_ticket_id, 's5', coalesce(p_s5,'-'));

  return v_ticket_id;
end $function$
