-- ============================================
-- RPC: crear match desde fixture AF
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
  v_home text;
  v_away text;
  v_league text;
  v_match_id bigint;
begin
  select * into v_fx from af_fixtures where id = p_fixture_id;
  if not found then
    raise exception 'Fixture % no encontrado', p_fixture_id;
  end if;

  select name into v_home from af_teams where id = v_fx.home_team_id;
  select name into v_away from af_teams where id = v_fx.away_team_id;
  select name into v_league from af_leagues where id = v_fx.league_id;

  insert into matches(start_time, lock_time, league, home_team, away_team,
                      af_fixture_id, status, created_at)
  values (
    v_fx.date,
    v_fx.date - make_interval(mins => coalesce(p_lock_minutes_before,10)),
    coalesce(v_league,'League'),
    coalesce(v_home,'Home'),
    coalesce(v_away,'Away'),
    v_fx.id,
    'NS',
    now()
  )
  returning id into v_match_id;

  return v_match_id;
end $$;

grant execute on function public.create_match_from_fixture(bigint,int) to authenticated;
