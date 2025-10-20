CREATE OR REPLACE FUNCTION public.submit_ticket(p_match_id bigint, p_s1 text, p_s2 text, p_s3 text, p_s4 text, p_s5 text)
 RETURNS TABLE(ticket_id bigint, duplicate boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
declare
  v_user uuid;
  v_ticket_id bigint;
  v_locked boolean;
  v_duplicate boolean;
  v_canonical text;
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

  -- Normalizamos la combinada entrante para comparar sin importar el orden
  v_canonical := (
    select string_agg(concat(key, '=', val), '|' order by key)
    from (values
      ('s1', coalesce(nullif(trim(p_s1), ''), '-')),
      ('s2', coalesce(nullif(trim(p_s2), ''), '-')),
      ('s3', coalesce(nullif(trim(p_s3), ''), '-')),
      ('s4', coalesce(nullif(trim(p_s4), ''), '-')),
      ('s5', coalesce(nullif(trim(p_s5), ''), '-'))
    ) as pick(key, val)
  );

  -- Buscamos si el usuario ya tiene la misma combinada (sin importar orden)
  select true
    into v_duplicate
  from (
    select (
      select string_agg(concat(key, '=', val), '|' order by key)
      from (values
        ('s1', coalesce(max(case when ta.q_key = 's1' then nullif(trim(ta.value), '') end), '-')),
        ('s2', coalesce(max(case when ta.q_key = 's2' then nullif(trim(ta.value), '') end), '-')),
        ('s3', coalesce(max(case when ta.q_key = 's3' then nullif(trim(ta.value), '') end), '-')),
        ('s4', coalesce(max(case when ta.q_key = 's4' then nullif(trim(ta.value), '') end), '-')),
        ('s5', coalesce(max(case when ta.q_key = 's5' then nullif(trim(ta.value), '') end), '-'))
      ) as existing(key, val)
    ) as canonical
    from tickets t
    left join ticket_answers ta
      on ta.ticket_id = t.id
     and ta.q_key in ('s1','s2','s3','s4','s5')
    where t.user_id = v_user
      and t.match_id = p_match_id
      and t.status = 'SUBMITTED'
    group by t.id
  ) combos
  where combos.canonical = v_canonical
  limit 1;

  if coalesce(v_duplicate, false) then
    ticket_id := null;
    duplicate := true;
    return next;
    return;
  end if;

  -- Insertamos un ticket nuevo (ya no reutilizamos el anterior)
  insert into tickets(user_id, match_id, status, submitted_at)
  values (v_user, p_match_id, 'SUBMITTED', now())
  returning id into v_ticket_id;

  insert into ticket_answers(ticket_id, q_key, value) values
    (v_ticket_id, 's1', coalesce(nullif(trim(p_s1), ''), '-')),
    (v_ticket_id, 's2', coalesce(nullif(trim(p_s2), ''), '-')),
    (v_ticket_id, 's3', coalesce(nullif(trim(p_s3), ''), '-')),
    (v_ticket_id, 's4', coalesce(nullif(trim(p_s4), ''), '-')),
    (v_ticket_id, 's5', coalesce(nullif(trim(p_s5), ''), '-'));

  ticket_id := v_ticket_id;
  duplicate := false;
  return next;
  return;
end
$function$
