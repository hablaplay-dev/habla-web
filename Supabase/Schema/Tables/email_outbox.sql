CREATE TABLE public.email_outbox (
  id bigint DEFAULT nextval('email_outbox_id_seq'::regclass) NOT NULL,
  to_email text NOT NULL,
  subject text NOT NULL,
  content_text text,
  content_html text,
  meta_json jsonb DEFAULT '{}'::jsonb,
  status text DEFAULT 'PENDING'::text NOT NULL,
  error text,
  sent_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now()
);
