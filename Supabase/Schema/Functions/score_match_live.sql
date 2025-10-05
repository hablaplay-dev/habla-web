CREATE OR REPLACE FUNCTION public.score_match_live(p_match_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  m          record;
  fx         record;
  g_h        int;  -- goles actuales home
  g_a        int;  -- goles actuales away
  r_h        int;  -- rojas actuales home
  r_a        int;  -- rojas actuales away
  is_ft      boolean;
  res_1x2    text;     -- 'HOME' | 'DRAW' | 'AWAY'
  btts_now   boolean;
  over25_now boolean;
  red_now    boolean;
  exact_ok   boolean;

  -- respuestas por ticket
  t          record;
  s1 text; s2 text; s3 text; s4 text; s5 text;
  pts int;
begin
  -- 0) match + fixture
  select * into m from public.matches where id = p_match_id;
  if not found then
    raise exception 'score_match_live: match % no existe', p_match_id;
  end if;
  if m.af_fixture_id is null then
    raise exception 'score_match_live: match % no tiene af_fixture_id', p_match_id;
  end if;

  select * into fx from public.af_fixtures where id = m.af_fixture_id;
  if not found then
    raise exception 'score_match_live: fixture % no existe', m.af_fixture_id;
  end if;

  -- 1) estado actual (preferir "goals_*" como live; si FT, score_ft_* es el final)
  g_h := coalesce(fx.goals_home, fx.score_ft_home, 0);
  g_a := coalesce(fx.goals_away, fx.score_ft_away, 0);
  r_h := coalesce(fx.red_home, 0);
  r_a := coalesce(fx.red_away, 0);

  is_ft := (coalesce(fx.status_short,'') = 'FT');

  -- 2) derivados en vivo
  res_1x2 := case when g_h > g_a then 'HOME'
                  when g_h = g_a then 'DRAW'
                  else 'AWAY' end;
  btts_now   := (g_h > 0 and g_a > 0);
  over25_now := ((g_h + g_a) > 2);
  red_now    := ((r_h + r_a) >= 1);

  -- 3) iterar tickets del match y calcular puntos live
  for t in
    select id as ticket_id
    from public.tickets
    where match_id = p_match_id
  loop
    -- leer respuestas
    select value into s1 from public.ticket_answers where ticket_id = t.ticket_id and q_key='s1'; -- 1X2: HOME/DRAW/AWAY
    select value into s2 from public.ticket_answers where ticket_id = t.ticket_id and q_key='s2'; -- BTTS: YES/NO
    select value into s3 from public.ticket_answers where ticket_id = t.ticket_id and q_key='s3'; -- OVER25: OVER/UNDER
    select value into s4 from public.ticket_answers where ticket_id = t.ticket_id and q_key='s4'; -- RED: YES/NO
    select value into s5 from public.ticket_answers where ticket_id = t.ticket_id and q_key='s5'; -- SCORE: "2-1"

    pts := 0;

    -- s1: 1X2 (3 pts)
    if s1 is not null and upper(s1) = res_1x2 then
      pts := pts + 3;
    end if;

    -- s2: BTTS (2 pts)
    if s2 is not null and (
         (upper(s2) = 'YES' and btts_now is true)
      or (upper(s2) = 'NO'  and btts_now is false)
    ) then
      pts := pts + 2;
    end if;

    -- s3: ±2.5 (2 pts)
    if s3 is not null and (
         (upper(s3) = 'OVER'  and over25_now is true)
      or (upper(s3) = 'UNDER' and over25_now is false)
    ) then
      pts := pts + 2;
    end if;

    -- s4: Roja (6 pts)
    if s4 is not null and (
         (upper(s4) = 'YES' and red_now is true)
      or (upper(s4) = 'NO'  and red_now is false)
    ) then
      pts := pts + 6;
    end if;

    -- s5: marcador exacto (8 pts) — en vivo sólo suma si coincide exacto en ese momento
    exact_ok := false;
    if s5 is not null and position('-' in s5) > 0 then
      exact_ok := (split_part(s5,'-',1)::int = g_h and split_part(s5,'-',2)::int = g_a);
      if exact_ok then pts := pts + 8; end if;
    end if;

    -- upsert en live
    insert into public.ticket_scores_live(ticket_id, match_id, points, details_json, updated_at, is_final)
    values (
      t.ticket_id,
      p_match_id,
      pts,
      jsonb_build_object(
        's1', (s1 is not null and upper(s1)=res_1x2),
        's2', (s2 is not null and ((upper(s2)='YES')=btts_now)),
        's3', (s3 is not null and ((upper(s3)='OVER')=over25_now)),
        's4', (s4 is not null and ((upper(s4)='YES')=red_now)),
        's5', exact_ok
      ),
      now(),
      is_ft
    )
    on conflict (ticket_id) do update
      set points      = excluded.points,
          details_json= excluded.details_json,
          updated_at  = now(),
          is_final    = excluded.is_final;
  end loop;

  -- 4) si ya es FT, consolidar histórico (SIMPLE): copiar finales a matches + ticket_scores + match_results y marcar tickets
  if is_ft then
    -- finales para matches
    update public.matches
       set final_home = coalesce(fx.score_ft_home, fx.goals_home, 0),
           final_away = coalesce(fx.score_ft_away, fx.goals_away, 0),
           result_1x2 = res_1x2,
           btts       = btts_now,
           over_25    = over25_now,
           red_home   = r_h,
           red_away   = r_a,
           status     = 'FT',
           last_sync_at = now()
     where id = p_match_id;

    -- snapshot histórico
    insert into public.match_results(match_id, score_home, score_away, red_home, red_away, meta_json)
    values (
      p_match_id,
      coalesce(fx.score_ft_home, fx.goals_home, 0),
      coalesce(fx.score_ft_away, fx.goals_away, 0),
      r_h, r_a,
      jsonb_build_object(
        'status_short', fx.status_short,
        'status_long',  fx.status_long,
        'ht', jsonb_build_object('home', fx.score_ht_home, 'away', fx.score_ht_away),
        'et', jsonb_build_object('home', fx.score_et_home, 'away', fx.score_et_away),
        'p',  jsonb_build_object('home', fx.score_p_home,  'away', fx.score_p_away)
      )
    )
    on conflict (match_id) do update
      set score_home = excluded.score_home,
          score_away = excluded.score_away,
          red_home   = excluded.red_home,
          red_away   = excluded.red_away,
          ended_at   = now(),
          meta_json  = excluded.meta_json;

    -- copiar live → ticket_scores final y marcar tickets
    insert into public.ticket_scores(ticket_id, match_id, points, details_json, scored_at)
    select tsl.ticket_id, tsl.match_id, tsl.points, tsl.details_json, now()
    from public.ticket_scores_live tsl
    where tsl.match_id = p_match_id
    on conflict (ticket_id) do update
      set points       = excluded.points,
          details_json = excluded.details_json,
          scored_at    = now();

    update public.tickets
       set status = 'SCORED'
     where match_id = p_match_id;
  end if;
end
$function$
