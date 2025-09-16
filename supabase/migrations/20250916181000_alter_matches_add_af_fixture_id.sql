-- ============================================
-- Alter matches: agregar referencia al fixture
-- ============================================
alter table public.matches
  add column if not exists af_fixture_id bigint references af_fixtures(id) on delete set null;
