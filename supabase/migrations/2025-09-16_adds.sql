-- ============================================
-- Tablas espejo de API-FOOTBALL
-- ============================================
create table if not exists public.af_leagues (
  id bigint primary key,
  name text not null,
  country text,
  logo text,
  type text,
  seasons jsonb not null default '[]'
);

create table if not exists public.af_teams (
  id bigint primary key,
  name text not null,
  country text,
  logo text
);

create table if not exists public.af_fixtures (
  id bigint primary key,
  league_id bigint not null,
  season int,
  date timestamptz,
  status_short text,
  status_long text,
  minute int,
  referee text,
  venue text,
  home_team_id bigint,
  away_team_id bigint,
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
create index if not exists idx_af_fixtures_date on public.af_fixtures(date);

-- ============================================
-- Ajustes en matches para enlazar fixtures
-- ============================================
alter table public.matches
  add column if not exists af_fixture_id bigint,
  add column if not exists status text check (status in ('NS','LIVE','FT')) default 'NS',
  add column if not exists score_home int,
  add column if not exists score_away int,
  add column if not exists live_minute int,
  add column if not exists last_sync_at timestamptz;

create index if not exists idx_matches_af_fixture on public.matches(af_fixture_id);
