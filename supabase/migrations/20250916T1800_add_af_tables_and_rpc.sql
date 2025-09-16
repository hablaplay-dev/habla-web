-- ============================================
-- AF · Tablas espejo de API-FOOTBALL
-- ============================================

create table if not exists public.af_leagues (
  id bigint primary key,
  name text not null,
  country text,
  logo text,
  type text,
  seasons jsonb default '[]'::jsonb
);

create table if not exists public.af_teams (
  id bigint primary key,
  name text not null,
  country text,
  logo text
);

create table if not exists public.af_fixtures (
  id bigint primary key,
  league_id bigint references public.af_leagues(id) on delete set null,
  season int,
  date timestamptz not null,
  status_short text,
  status_long text,
  minute int,
  referee text,
  venue text,
  home_team_id bigint references public.af_teams(id) on delete set null,
  away_team_id bigint references public.af_teams(id) on delete set null,
  goals_home int,
  goals_away int,
  score_ht_home int,
  score_ht_away int,
  score_ft_home int,
  score_ft_away int,
  score_et_home int,
  score_et_away int,
  score_p_home int,
  score_p_away int,
  last_sync_at timestamptz
);

-- ============================================
-- RPC: crear match desde un fixture
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
  v_lock timestamptz;
begin
  select * into v_fx from af_fixtures where id = p_fixture_id;
  if not found then
    raise exception 'Fixture % no existe en af_fixtures', p_fixture_id;
  end if;

  v_lock := v_fx.date - make_interval(mins => p_lock_minutes_before);

  insert into matches(start_time, lock_time, league, home_team, away_team, bonus_id, created_at)
  values (
    v_fx.date,
    v_lock,
    coalesce((select name from af_leagues where id = v_fx.league_id), 'Unknown League'),
    coalesce((select name from af_teams where id = v_fx.home_team_id), 'Home'),
    coalesce((select name from af_teams where id = v_fx.away_team_id), 'Away'),
    null,
    now()
  )
  returning id into v_match_id;

  update matches set af_fixture_id = v_fx.id where id = v_match_id;

  return v_match_id;
end $$;

grant execute on function public.create_match_from_fixture(bigint, int) to service_role;
