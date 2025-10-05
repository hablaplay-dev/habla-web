CREATE OR REPLACE FUNCTION public.get_profile_status()
 RETURNS TABLE(user_id uuid, email text, email_verified boolean, username text, full_name text, avatar_url text, favorite_team text, dob date, is_adult boolean, twofa_enabled boolean, payout_method text, payout_detail text, notify_email boolean, notify_push boolean, lang text, profile_public boolean, created_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    p.user_id,
    u.email,
    (u.email_confirmed_at is not null) as email_verified,
    coalesce(p.username, (u.raw_user_meta_data->>'username')) as username, -- toma de profiles o metadata
    p.full_name,
    p.avatar_url,
    p.favorite_team,
    p.dob,
    p.is_adult,
    p.twofa_enabled,
    p.payout_method,
    p.payout_detail,
    p.notify_email,
    p.notify_push,
    p.lang,
    p.profile_public,
    p.created_at
  from profiles p
  join auth.users u on u.id = p.user_id
  where p.user_id = auth.uid()
$function$
