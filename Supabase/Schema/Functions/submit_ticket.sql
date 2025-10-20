CREATE OR REPLACE FUNCTION public.submit_ticket(p_match_id bigint, p_s1 text, p_s2 text, p_s3 text, p_s4 text, p_s5 text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid;
  v_ticket_id bigint;
  v_locked boolean;
  v_duplicate_ticket_id bigint;
  v_picks jsonb;
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

  v_picks := jsonb_build_object(
    's1', coalesce(p_s1, '-'),
    's2', coalesce(p_s2, '-'),
    's3', coalesce(p_s3, '-'),
    's4', coalesce(p_s4, '-'),
    's5', coalesce(p_s5, '-')
  );

  select existing.id
    into v_duplicate_ticket_id
  from (
    select t.id,
           t.submitted_at,
           coalesce(jsonb_object_agg(ta.q_key, ta.value), '{}'::jsonb) as picks
      from public.tickets t
      left join public.ticket_answers ta
        on ta.ticket_id = t.id
     where t.user_id = v_user
       and t.match_id = p_match_id
     group by t.id, t.submitted_at
  ) as existing
  where existing.picks = v_picks
  order by existing.submitted_at desc, existing.id desc
  limit 1;

  if v_duplicate_ticket_id is not null then
    return jsonb_build_object('ticket_id', v_duplicate_ticket_id, 'duplicate', true);
  end if;

  insert into tickets(user_id, match_id, status, submitted_at)
  values (v_user, p_match_id, 'SUBMITTED', now())
  returning id into v_ticket_id;

  insert into ticket_answers(ticket_id, q_key, value) values
    (v_ticket_id, 's1', coalesce(p_s1,'-')),
    (v_ticket_id, 's2', coalesce(p_s2,'-')),
    (v_ticket_id, 's3', coalesce(p_s3,'-')),
    (v_ticket_id, 's4', coalesce(p_s4,'-')),
    (v_ticket_id, 's5', coalesce(p_s5,'-'));

  return jsonb_build_object('ticket_id', v_ticket_id, 'duplicate', false);
end $function$
