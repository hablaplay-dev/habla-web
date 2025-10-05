CREATE TABLE public.ticket_scores (
  ticket_id bigint NOT NULL,
  match_id bigint NOT NULL,
  points integer NOT NULL,
  details_json jsonb DEFAULT '{}'::jsonb,
  scored_at timestamp with time zone DEFAULT now() NOT NULL
);
