CREATE TABLE public.seed_audit (
  id bigint DEFAULT nextval('seed_audit_id_seq'::regclass) NOT NULL,
  run_at timestamp with time zone DEFAULT now() NOT NULL,
  target_date date NOT NULL,
  leagues text,
  season integer,
  ok boolean DEFAULT false NOT NULL,
  note text
);
