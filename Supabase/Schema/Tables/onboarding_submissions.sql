CREATE TABLE public.onboarding_submissions (
  id bigint DEFAULT nextval('onboarding_submissions_id_seq'::regclass) NOT NULL,
  user_id uuid NOT NULL,
  full_name text,
  favorite_team text,
  dob date,
  is_adult boolean DEFAULT false NOT NULL,
  avatar_url text,
  lang text DEFAULT 'Español'::text,
  notify_email boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);
