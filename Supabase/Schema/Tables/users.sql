CREATE TABLE public.users (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid,
  name character varying(255) NOT NULL,
  last_name character varying(255) NOT NULL,
  id_type character varying(50) NOT NULL,
  id_number character varying(255) NOT NULL,
  phone_code character varying(10) NOT NULL,
  phone_number character varying(20) NOT NULL,
  country character varying(100) NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  activated boolean DEFAULT false NOT NULL
);
