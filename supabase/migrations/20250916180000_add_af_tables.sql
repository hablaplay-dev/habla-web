-- ============================================
-- AF Tables para API-Football
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
  league_id bigint references af_leagues(id),
  season int,
  date timestamptz,
  status_short text,
  status_long text,
  minute int,
  referee text,
  venue text,
  home_team_id bigint references af_teams(id),
  away_team_id bigint references af_teams(id),
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
