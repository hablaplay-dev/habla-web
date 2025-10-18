/* =======================
   GRANTS EXPORT (schema: public)
   Generado: 2025-10-18 23:07:35.905629+00
   Nota: líneas REVOKE están comentadas.
======================== */

-- ===== TABLES & VIEWS =====
-- public.af_fixtures
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.af_fixtures FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_fixtures TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_fixtures TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_fixtures TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_fixtures TO service_role;

-- public.af_leagues
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.af_leagues FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_leagues TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_leagues TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_leagues TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_leagues TO service_role;

-- public.af_teams
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.af_teams FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_teams TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_teams TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_teams TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.af_teams TO service_role;

-- public.app_config
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.app_config FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.app_config TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.app_config TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.app_config TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.app_config TO service_role;

-- public.email_outbox
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.email_outbox FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.email_outbox TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.email_outbox TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.email_outbox TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.email_outbox TO service_role;

-- public.match_results
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.match_results FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.match_results TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.match_results TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.match_results TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.match_results TO service_role;

-- public.matches
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.matches FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.matches TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.matches TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.matches TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.matches TO service_role;

-- public.onboarding_submissions
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.onboarding_submissions FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.onboarding_submissions TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.onboarding_submissions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.onboarding_submissions TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.onboarding_submissions TO service_role;

-- public.profiles
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.profiles FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.profiles TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.profiles TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.profiles TO service_role;

-- public.seed_audit
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.seed_audit FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.seed_audit TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.seed_audit TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.seed_audit TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.seed_audit TO service_role;

-- public.ticket_answers
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.ticket_answers FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_answers TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_answers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_answers TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_answers TO service_role;

-- public.ticket_scores
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.ticket_scores FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores TO service_role;

-- public.ticket_scores_live
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.ticket_scores_live FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores_live TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores_live TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores_live TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.ticket_scores_live TO service_role;

-- public.tickets
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.tickets FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.tickets TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.tickets TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.tickets TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.tickets TO service_role;

-- public.users
-- (Opcional) Estado canónico:
-- REVOKE ALL ON TABLE public.users FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.users TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.users TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.users TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE public.users TO service_role;

-- ===== SEQUENCES =====
-- public.email_outbox_id_seq
-- (Opcional) Estado canónico:
-- REVOKE ALL ON SEQUENCE public.email_outbox_id_seq FROM PUBLIC;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.email_outbox_id_seq TO anon;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.email_outbox_id_seq TO authenticated;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.email_outbox_id_seq TO postgres;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.email_outbox_id_seq TO service_role;

-- public.matches_id_seq
-- (Opcional) Estado canónico:
-- REVOKE ALL ON SEQUENCE public.matches_id_seq FROM PUBLIC;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.matches_id_seq TO anon;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.matches_id_seq TO authenticated;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.matches_id_seq TO postgres;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.matches_id_seq TO service_role;

-- public.onboarding_submissions_id_seq
-- (Opcional) Estado canónico:
-- REVOKE ALL ON SEQUENCE public.onboarding_submissions_id_seq FROM PUBLIC;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.onboarding_submissions_id_seq TO anon;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.onboarding_submissions_id_seq TO authenticated;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.onboarding_submissions_id_seq TO postgres;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.onboarding_submissions_id_seq TO service_role;

-- public.seed_audit_id_seq
-- (Opcional) Estado canónico:
-- REVOKE ALL ON SEQUENCE public.seed_audit_id_seq FROM PUBLIC;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.seed_audit_id_seq TO anon;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.seed_audit_id_seq TO authenticated;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.seed_audit_id_seq TO postgres;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.seed_audit_id_seq TO service_role;

-- public.ticket_answers_id_seq
-- (Opcional) Estado canónico:
-- REVOKE ALL ON SEQUENCE public.ticket_answers_id_seq FROM PUBLIC;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.ticket_answers_id_seq TO anon;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.ticket_answers_id_seq TO authenticated;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.ticket_answers_id_seq TO postgres;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.ticket_answers_id_seq TO service_role;

-- public.tickets_id_seq
-- (Opcional) Estado canónico:
-- REVOKE ALL ON SEQUENCE public.tickets_id_seq FROM PUBLIC;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.tickets_id_seq TO anon;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.tickets_id_seq TO authenticated;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.tickets_id_seq TO postgres;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE public.tickets_id_seq TO service_role;

-- ===== FUNCTIONS =====
-- (Sin GRANTs de funciones para el esquema public)
