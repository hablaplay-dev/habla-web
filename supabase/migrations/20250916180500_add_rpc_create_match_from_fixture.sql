-- ============================================
-- RPC: create_match_from_fixture
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
  v_fixture af_fixtures%rowtype;
  v_match_id bigint;
begin
  select * into v_fixture from af_fixtures where id = p_fixture_id;
  if not found then
    raise exception 'Fixture % no encontrado en af_fixtures', p_fixture_id;
  end if;

  insert into matches(start_time, lock_time, league, home_team, away_team, bonus_id, created_at, af_fixture_id)
  values (
    v_fixture.date,
    v_fixture.date - (p_lock_minutes_before || ' minutes')::interval,
    (select name from af_leagues where id = v_fixture.league_id),
    (select name from af_teams where id = v_fixture.home_team_id),
    (select name from af_teams where id = v_fixture.away_team_id),
    null,
    now(),
    v_fixture.id
  )
  returning id into v_match_id;

  return v_match_id;
end
$$;

grant execute on function public.create_match_from_fixture(bigint,int) to service_role;
