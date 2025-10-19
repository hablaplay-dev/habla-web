-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.af_fixtures (
  id bigint NOT NULL,
  league_id bigint,
  season integer,
  date timestamp with time zone NOT NULL,
  status_short text,
  status_long text,
  minute integer,
  referee text,
  venue text,
  home_team_id bigint,
  away_team_id bigint,
  goals_home integer,
  goals_away integer,
  score_ht_home integer,
  score_ht_away integer,
  score_ft_home integer,
  score_ft_away integer,
  score_et_home integer,
  score_et_away integer,
  score_p_home integer,
  score_p_away integer,
  last_sync_at timestamp with time zone,
  red_home integer,
  red_away integer,
  CONSTRAINT af_fixtures_pkey PRIMARY KEY (id),
  CONSTRAINT af_fixtures_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.af_leagues(id),
  CONSTRAINT af_fixtures_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES public.af_teams(id),
  CONSTRAINT af_fixtures_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES public.af_teams(id)
);
CREATE TABLE public.af_leagues (
  id bigint NOT NULL,
  name text NOT NULL,
  country text,
  logo text,
  type text,
  seasons jsonb DEFAULT '[]'::jsonb,
  CONSTRAINT af_leagues_pkey PRIMARY KEY (id)
);
CREATE TABLE public.af_teams (
  id bigint NOT NULL,
  name text NOT NULL,
  country text,
  logo text,
  CONSTRAINT af_teams_pkey PRIMARY KEY (id)
);
CREATE TABLE public.app_config (
  key text NOT NULL,
  value text NOT NULL,
  CONSTRAINT app_config_pkey PRIMARY KEY (key)
);
CREATE TABLE public.email_outbox (
  id bigint NOT NULL DEFAULT nextval('email_outbox_id_seq'::regclass),
  to_email text NOT NULL,
  subject text NOT NULL,
  content_text text,
  content_html text,
  meta_json jsonb DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'PENDING'::text CHECK (status = ANY (ARRAY['PENDING'::text, 'SENT'::text, 'FAILED'::text])),
  error text,
  sent_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT email_outbox_pkey PRIMARY KEY (id)
);
CREATE TABLE public.match_results (
  match_id bigint NOT NULL,
  ended_at timestamp with time zone NOT NULL DEFAULT now(),
  score_home integer NOT NULL,
  score_away integer NOT NULL,
  red_home integer DEFAULT 0,
  red_away integer DEFAULT 0,
  meta_json jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT match_results_pkey PRIMARY KEY (match_id),
  CONSTRAINT match_results_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id)
);
CREATE TABLE public.matches (
  id bigint NOT NULL DEFAULT nextval('matches_id_seq'::regclass),
  start_time timestamp with time zone NOT NULL,
  lock_time timestamp with time zone NOT NULL,
  league text NOT NULL,
  home_team text NOT NULL,
  away_team text NOT NULL,
  dur_min integer DEFAULT 110,
  bonus_id bigint,
  created_at timestamp with time zone DEFAULT now(),
  af_fixture_id bigint UNIQUE,
  status text,
  score_home integer,
  score_away integer,
  live_minute integer,
  last_sync_at timestamp with time zone,
  red_home integer,
  red_away integer,
  result_1x2 text CHECK (result_1x2 = ANY (ARRAY['HOME'::text, 'DRAW'::text, 'AWAY'::text])),
  btts boolean,
  over_25 boolean,
  final_home integer,
  final_away integer,
  CONSTRAINT matches_pkey PRIMARY KEY (id)
);
CREATE TABLE public.onboarding_submissions (
  id bigint NOT NULL DEFAULT nextval('onboarding_submissions_id_seq'::regclass),
  user_id uuid NOT NULL,
  full_name text,
  favorite_team text,
  dob date,
  is_adult boolean NOT NULL DEFAULT false,
  avatar_url text,
  lang text DEFAULT 'Español'::text,
  notify_email boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT onboarding_submissions_pkey PRIMARY KEY (id),
  CONSTRAINT onboarding_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  user_id uuid NOT NULL,
  dob date,
  is_adult boolean NOT NULL DEFAULT false,
  full_name text,
  favorite_team text,
  lang text DEFAULT 'Español'::text,
  created_at timestamp with time zone DEFAULT now(),
  avatar_url text,
  twofa_enabled boolean DEFAULT false,
  payout_method text,
  payout_detail text,
  notify_email boolean DEFAULT true,
  notify_push boolean DEFAULT true,
  profile_public boolean DEFAULT true,
  username text,
  CONSTRAINT profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.seed_audit (
  id bigint NOT NULL DEFAULT nextval('seed_audit_id_seq'::regclass),
  run_at timestamp with time zone NOT NULL DEFAULT now(),
  target_date date NOT NULL,
  leagues text,
  season integer,
  ok boolean NOT NULL DEFAULT false,
  note text,
  CONSTRAINT seed_audit_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ticket_answers (
  id bigint NOT NULL DEFAULT nextval('ticket_answers_id_seq'::regclass),
  ticket_id bigint NOT NULL,
  q_key text NOT NULL CHECK (q_key = ANY (ARRAY['s1'::text, 's2'::text, 's3'::text, 's4'::text, 's5'::text])),
  value text NOT NULL,
  CONSTRAINT ticket_answers_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_answers_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.ticket_scores (
  ticket_id bigint NOT NULL,
  match_id bigint NOT NULL,
  points integer NOT NULL,
  details_json jsonb DEFAULT '{}'::jsonb,
  scored_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_scores_pkey PRIMARY KEY (ticket_id),
  CONSTRAINT ticket_scores_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_scores_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id)
);
CREATE TABLE public.ticket_scores_live (
  ticket_id bigint NOT NULL,
  match_id bigint NOT NULL,
  points integer NOT NULL,
  details_json jsonb DEFAULT '{}'::jsonb,
  is_final boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_scores_live_pkey PRIMARY KEY (ticket_id),
  CONSTRAINT ticket_scores_live_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_scores_live_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id)
);
CREATE TABLE public.tickets (
  id bigint NOT NULL DEFAULT nextval('tickets_id_seq'::regclass),
  user_id uuid NOT NULL,
  match_id bigint NOT NULL,
  status text NOT NULL DEFAULT 'SUBMITTED'::text CHECK (status = ANY (ARRAY['SUBMITTED'::text, 'LOCKED'::text, 'SCORED'::text])),
  submitted_at timestamp with time zone DEFAULT now(),
  locked_at timestamp with time zone,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT tickets_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  name character varying NOT NULL,
  last_name character varying NOT NULL,
  id_type character varying NOT NULL,
  id_number character varying NOT NULL,
  phone_code character varying NOT NULL,
  phone_number character varying NOT NULL,
  country character varying NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  activated boolean NOT NULL DEFAULT false,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

-- Function: public.get_match_tickets_with_picks
CREATE OR REPLACE FUNCTION public.get_match_tickets_with_picks(p_match_id bigint)
 RETURNS TABLE(rank integer, ticket_id bigint, user_id uuid, full_name text, username text, avatar_url text, submitted_at timestamp with time zone, s1 text, s2 text, s3 text, s4 text, s5 text, score integer, score_updated_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  WITH submitted AS (
    SELECT t.id, t.user_id, t.match_id, t.submitted_at
    FROM public.tickets t
    WHERE t.match_id = p_match_id
      AND t.status = 'SUBMITTED'
  ), answers AS (
    SELECT
      ta.ticket_id,
      jsonb_object_agg(ta.q_key, ta.value) AS picks
    FROM public.ticket_answers ta
    JOIN submitted s ON s.id = ta.ticket_id
    GROUP BY ta.ticket_id
  ), enriched AS (
    SELECT
      s.id AS ticket_id,
      s.user_id,
      s.submitted_at,
      p.full_name,
      p.username,
      p.avatar_url,
      COALESCE(a.picks, '{}'::jsonb) AS picks,
      tsl.points AS score,
      tsl.updated_at AS score_updated_at
    FROM submitted s
    LEFT JOIN public.profiles p ON p.user_id = s.user_id
    LEFT JOIN answers a ON a.ticket_id = s.id
    LEFT JOIN public.ticket_scores_live tsl
      ON tsl.ticket_id = s.id
     AND tsl.match_id = s.match_id
  ), ranked AS (
    SELECT
      e.*,
      CASE
        WHEN EXISTS (
          SELECT 1
          FROM public.ticket_scores_live tsl
          WHERE tsl.match_id = p_match_id
        )
          THEN dense_rank() OVER (ORDER BY e.score DESC NULLS LAST, e.submitted_at ASC)
        ELSE row_number() OVER (ORDER BY e.submitted_at ASC)
      END AS rank
    FROM enriched e
  )
  SELECT
    r.rank,
    r.ticket_id,
    r.user_id,
    r.full_name,
    r.username,
    r.avatar_url,
    r.submitted_at,
    r.picks ->> 's1' AS s1,
    r.picks ->> 's2' AS s2,
    r.picks ->> 's3' AS s3,
    r.picks ->> 's4' AS s4,
    r.picks ->> 's5' AS s5,
    r.score,
    r.score_updated_at
  FROM ranked r
  ORDER BY
    CASE WHEN r.score IS NOT NULL THEN 0 ELSE 1 END,
    r.score DESC,
    r.submitted_at ASC;
$function$
