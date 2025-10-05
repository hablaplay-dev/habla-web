CREATE TABLE public.profiles (
  user_id uuid NOT NULL,
  dob date,
  is_adult boolean DEFAULT false NOT NULL,
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
  username text
);
