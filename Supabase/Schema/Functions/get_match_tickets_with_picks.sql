CREATE OR REPLACE FUNCTION public.get_match_tickets_with_picks(p_match_id bigint)
  RETURNS TABLE(
    rank integer,
    ticket_id bigint,
    user_id uuid,
    full_name text,
    username text,
    avatar_url text,
    submitted_at timestamp with time zone,
    s1 text,
    s2 text,
    s3 text,
    s4 text,
    s5 text,
    score integer,
    score_updated_at timestamp with time zone
  )
  LANGUAGE sql
  STABLE SECURITY DEFINER
  SET search_path TO 'public', 'auth'
AS $function$
  WITH submitted AS (
    SELECT t.id, t.user_id, t.match_id, t.submitted_at
    FROM public.tickets t
    WHERE t.match_id = p_match_id
      AND t.status = 'SUBMITTED'
  ), answers AS (
    SELECT
      ta.ticket_id,
      jsonb_object_agg(ta.q_key, ta.value) AS picks
    FROM public.ticket_answers ta
    JOIN submitted s ON s.id = ta.ticket_id
    GROUP BY ta.ticket_id
  ), enriched AS (
    SELECT
      s.id AS ticket_id,
      s.user_id,
      s.submitted_at,
      p.full_name,
      p.username,
      p.avatar_url,
      COALESCE(a.picks, '{}'::jsonb) AS picks,
      tsl.points AS score,
      tsl.updated_at AS score_updated_at
    FROM submitted s
    LEFT JOIN public.profiles p ON p.user_id = s.user_id
    LEFT JOIN answers a ON a.ticket_id = s.id
    LEFT JOIN public.ticket_scores_live tsl
      ON tsl.ticket_id = s.id
     AND tsl.match_id = s.match_id
  ), ranked AS (
    SELECT
      e.*,
      CASE
        WHEN EXISTS (
          SELECT 1
          FROM public.ticket_scores_live tsl
          WHERE tsl.match_id = p_match_id
        )
          THEN dense_rank() OVER (ORDER BY e.score DESC NULLS LAST, e.submitted_at ASC)
        ELSE row_number() OVER (ORDER BY e.submitted_at ASC)
      END AS rank
    FROM enriched e
  )
  SELECT
    r.rank,
    r.ticket_id,
    r.user_id,
    r.full_name,
    r.username,
    r.avatar_url,
    r.submitted_at,
    r.picks ->> 's1' AS s1,
    r.picks ->> 's2' AS s2,
    r.picks ->> 's3' AS s3,
    r.picks ->> 's4' AS s4,
    r.picks ->> 's5' AS s5,
    r.score,
    r.score_updated_at
  FROM ranked r
  ORDER BY
    CASE WHEN r.score IS NOT NULL THEN 0 ELSE 1 END,
    r.score DESC,
    r.submitted_at ASC;
$function$
