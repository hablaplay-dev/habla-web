-- ================================
-- API-FOOTBALL · Tablas de catálogo
-- ================================
create table if not exists af_leagues (
  id integer primary key,                 -- API-FOOTBALL league id
  name text not null,
  country text,
  logo text,
  type text,                              -- League/Cup
  seasons jsonb default '[]'::jsonb,      -- temporadas disponibles
  created_at timestamptz default now()
);

create table if not exists af_teams (
  id integer primary key,                 -- API-FOOTBALL team id
  name text not null,
  country text,
  logo text,
  created_at timestamptz default now()
);

-- ================================
-- API-FOOTBALL · Fixtures (partidos crudos)
-- ================================
create table if not exists af_fixtures (
  id integer primary key,                 -- API-FOOTBALL fixture id
  league_id integer not null references af_leagues(id) on delete restrict,
  season integer not null,
  date timestamptz not null,              -- kickoff (UTC)
  status_short text,                      -- NS, 1H, HT, 2H, ET, FT, PST, CANC, SUSP...
  status_long text,
  minute int,                             -- minuto en vivo (null si no live)
  referee text,
  venue text,
  home_team_id integer not null references af_teams(id) on delete restrict,
  away_team_id integer not null references af_teams(id) on delete restrict,
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
  last_sync_at timestamptz default now(),
  created_at timestamptz default now()
);

create index if not exists idx_af_fixtures_date on af_fixtures(date);
create index if not exists idx_af_fixtures_status on af_fixtures(status_short);

-- =========================================================
-- Enlazamos tus matches (MVP) con API-FOOTBALL (no rompemos)
-- =========================================================
alter table matches
  add column if not exists af_fixture_id integer,
  add column if not exists af_league_id integer,
  add column if not exists af_season integer,
  add column if not exists home_team_id integer,
  add column if not exists away_team_id integer,
  add column if not exists status text,                -- NS, LIVE, FT (normalizado)
  add column if not exists score_home int,
  add column if not exists score_away int,
  add column if not exists live_minute int,
  add column if not exists last_sync_at timestamptz;

-- Índices útiles
create index if not exists idx_matches_af_fixture   on matches(af_fixture_id);
create index if not exists idx_matches_status       on matches(status);
create index if not exists idx_matches_lock_time    on matches(lock_time);

-- =========================================================
-- Vista “presentable” para el FE (Results / Follow Live!)
-- =========================================================
create or replace view v_matches_public as
select
  m.id,
  m.start_time,
  m.lock_time,
  coalesce(l.name, m.league) as league_name,
  coalesce(ht.name, m.home_team) as home_team,
  coalesce(at.name, m.away_team) as away_team,
  ht.logo as home_logo,
  at.logo as away_logo,
  m.status,
  m.score_home,
  m.score_away,
  m.live_minute,
  m.af_fixture_id,
  m.af_league_id,
  m.af_season
from matches m
left join af_teams ht on ht.id = m.home_team_id
left join af_teams at on at.id = m.away_team_id
left join af_leagues l on l.id = m.af_league_id;

grant select on v_matches_public to anon, authenticated;

-- ================================
-- RLS (catálogos legibles; edición solo service-role)
-- ================================
alter table af_leagues  enable row level security;
alter table af_teams    enable row level security;
alter table af_fixtures enable row level security;

-- Lectura pública
drop policy if exists af_leagues_read on af_leagues;
create policy af_leagues_read on af_leagues for select to public using (true);

drop policy if exists af_teams_read on af_teams;
create policy af_teams_read on af_teams for select to public using (true);

drop policy if exists af_fixtures_read on af_fixtures;
create policy af_fixtures_read on af_fixtures for select to public using (true);

-- Insert/Update/Delete solo con service role (Edge Functions)
-- (sin policies → prohibido por RLS; usaremos service key en funciones)

-- ============================================
-- RPC: crear match desde un fixture seleccionado (gestor)
-- ============================================
drop function if exists create_match_from_fixture(integer, integer);
create or replace function create_match_from_fixture(p_fixture_id integer, p_lock_minutes_before int default 10)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  f af_fixtures%rowtype;
  v_match_id bigint;
begin
  select * into f from af_fixtures where id = p_fixture_id;
  if not found then
    raise exception 'Fixture % no encontrado', p_fixture_id;
  end if;

  -- Upsert equipos a texto amigable si aún no existen en matches
  insert into matches(
    start_time, lock_time, league, home_team, away_team, dur_min,
    af_fixture_id, af_league_id, af_season, home_team_id, away_team_id,
    status, score_home, score_away, live_minute, last_sync_at
  )
  values (
    f.date,
    (f.date - make_interval(mins => greatest(p_lock_minutes_before,0))),
    (select name from af_leagues where id=f.league_id),
    (select name from af_teams where id=f.home_team_id),
    (select name from af_teams where id=f.away_team_id),
    110,
    f.id, f.league_id, f.season, f.home_team_id, f.away_team_id,
    case f.status_short when 'NS' then 'NS' when 'FT' then 'FT' else 'NS' end,
    f.goals_home, f.goals_away, f.minute, now()
  )
  returning id into v_match_id;

  return v_match_id;
end $$;

grant execute on function create_match_from_fixture(integer, integer) to service_role; -- lo llamará la Edge Function
