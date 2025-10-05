CREATE OR REPLACE FUNCTION public.create_match_from_fixture(p_fixture_id bigint, p_lock_minutes_before integer DEFAULT 10)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_fx record;
  v_id bigint;
begin
  select * into v_fx
  from af_fixtures f
  where f.id = p_fixture_id;

  if not found then
    raise exception 'Fixture % not found in af_fixtures', p_fixture_id;
  end if;

  insert into matches(
    start_time,
    lock_time,
    league,
    home_team,
    away_team,
    created_at
  )
  values (
    v_fx.date,
    v_fx.date - (p_lock_minutes_before * interval '1 minute'),
    v_fx.league_id::text,
    (select name from af_teams where id = v_fx.home_team_id),
    (select name from af_teams where id = v_fx.away_team_id),
    now()
  )
  returning id into v_id;

  -- Relación: guardamos af_fixture_id en matches (agregar si no existe)
  update matches set af_fixture_id = p_fixture_id where id = v_id;

  return v_id;
end $function$
