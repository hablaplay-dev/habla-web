CREATE TABLE public.ticket_scores_live (
  ticket_id bigint NOT NULL,
  match_id bigint NOT NULL,
  points integer NOT NULL,
  details_json jsonb DEFAULT '{}'::jsonb,
  is_final boolean DEFAULT false NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);
