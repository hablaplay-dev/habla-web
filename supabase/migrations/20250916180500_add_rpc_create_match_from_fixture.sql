-- ============================================
-- RPC: crear un match en nuestra tabla "matches"
-- a partir de un fixture API-FOOTBALL
-- ============================================
create or replace function public.create_match_from_fixture(
  p_fixture_id bigint,
  p_lock_minutes_before int default 10
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_fx af_fixtures%rowtype;
  v_match_id bigint;
  v_start timestamptz;
  v_lock timestamptz;
begin
  select * into v_fx from af_fixtures where id = p_fixture_id;
  if not found then
    raise exception 'Fixture % not found', p_fixture_id;
  end if;

  v_start := v_fx.date;
  v_lock := v_start - make_interval(mins => coalesce(p_lock_minutes_before,10));

  insert into matches(start_time, lock_time, league, home_team, away_team, bonus_id, created_at, af_fixture_id)
  values (
    v_start,
    v_lock,
    coalesce((select name from af_leagues where id = v_fx.league_id), 'Unknown League'),
    coalesce((select name from af_teams where id = v_fx.home_team_id), 'Home'),
    coalesce((select name from af_teams where id = v_fx.away_team_id), 'Away'),
    null,
    now(),
    v_fx.id
  )
  returning id into v_match_id;

  return v_match_id;
end
$$;

-- Dar permisos a service role
grant execute on function public.create_match_from_fixture(bigint, int) to service_role;
