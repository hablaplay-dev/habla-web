CREATE OR REPLACE FUNCTION public.get_leaderboard(p_match_id bigint, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
 RETURNS TABLE(rank integer, ticket_id bigint, user_id uuid, username text, points integer, details jsonb, is_final boolean, updated_at timestamp with time zone)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  with base as (
    select
      t.id  as ticket_id,
      t.user_id,
      coalesce(u.raw_user_meta_data->>'username','') as username,
      s.points                as points,          -- <- columna correcta
      s.details_json          as details,
      s.is_final              as is_final,
      s.updated_at            as updated_at
    from public.tickets t
    join public.ticket_scores_live s
      on s.ticket_id = t.id
    join auth.users u
      on u.id = t.user_id
    where t.match_id = p_match_id
  ),
  ranked as (
    select
      dense_rank() over (order by points desc, updated_at asc) as rank,
      *
    from base
  )
  select
    r.rank, r.ticket_id, r.user_id, r.username,
    r.points, r.details, r.is_final, r.updated_at
  from ranked r
  order by r.rank, r.ticket_id
  limit greatest(p_limit, 1)
  offset greatest(p_offset, 0);
$function$
