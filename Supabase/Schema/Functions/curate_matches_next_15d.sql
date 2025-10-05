CREATE OR REPLACE FUNCTION public.curate_matches_next_15d(p_leagues bigint[] DEFAULT ARRAY[1, 2, 3, 4, 5, 9, 10, 11, 13, 15, 32, 34, 37, 39, 71, 73, 78, 128, 135, 140, 143, 281, 282, 531, 556, 558], p_days integer DEFAULT 15, p_lock_minutes_before integer DEFAULT 0)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_ins int := 0;
begin
  -- Inserta o ignora si ya existe (af_fixture_id es unique en matches)
  with cte as (
    select
      f.id          as af_fixture_id,
      f.date        as start_time,
      (f.date - (p_lock_minutes_before * interval '1 minute')) as lock_time,
      coalesce(l.name, f.league_id::text) as league,
      (select name from af_teams where id = f.home_team_id) as home_team,
      (select name from af_teams where id = f.away_team_id) as away_team
    from af_fixtures f
    join af_leagues l on l.id = f.league_id
    where f.date >= now()
      and f.date <  now() + make_interval(days => p_days)
      and f.league_id = any(p_leagues)
  )
  insert into matches(af_fixture_id, start_time, lock_time, league, home_team, away_team)
  select af_fixture_id, start_time, lock_time, league, home_team, away_team
  from cte
  on conflict (af_fixture_id) do nothing;

  get diagnostics v_ins = row_count;
  return v_ins;
end
$function$
