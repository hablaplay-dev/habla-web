CREATE TABLE public.match_results (
  match_id bigint NOT NULL,
  ended_at timestamp with time zone DEFAULT now() NOT NULL,
  score_home integer NOT NULL,
  score_away integer NOT NULL,
  red_home integer DEFAULT 0,
  red_away integer DEFAULT 0,
  meta_json jsonb DEFAULT '{}'::jsonb
);
