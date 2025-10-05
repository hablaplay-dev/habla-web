CREATE TABLE public.af_leagues (
  id bigint NOT NULL,
  name text NOT NULL,
  country text,
  logo text,
  type text,
  seasons jsonb DEFAULT '[]'::jsonb
);
