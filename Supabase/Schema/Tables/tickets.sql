CREATE TABLE public.tickets (
  id bigint DEFAULT nextval('tickets_id_seq'::regclass) NOT NULL,
  user_id uuid NOT NULL,
  match_id bigint NOT NULL,
  status text DEFAULT 'SUBMITTED'::text NOT NULL,
  submitted_at timestamp with time zone DEFAULT now(),
  locked_at timestamp with time zone
);
