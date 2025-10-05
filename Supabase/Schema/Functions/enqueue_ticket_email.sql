CREATE OR REPLACE FUNCTION public.enqueue_ticket_email()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_email   text;
  v_league  text;
  v_home    text;
  v_away    text;
begin
  select email into v_email
  from auth.users
  where id = new.user_id;

  select league, home_team, away_team
    into v_league, v_home, v_away
  from matches
  where id = new.match_id;

  insert into email_outbox(to_email, subject, content_text, content_html, meta_json)
  values (
    coalesce(v_email, ''), 
    'Your Habla! ticket is in ✅',
    format(
      'You joined %s: %s vs %s. Ticket #%s',
      coalesce(v_league,'League'),
      coalesce(v_home,'Home'),
      coalesce(v_away,'Away'),
      new.id::text
    ),
    format(
      '<p>You joined <b>%s</b>: <b>%s vs %s</b>.</p><p>Ticket <b>#%s</b>. Good luck! ⚽️</p>',
      coalesce(v_league,'League'),
      coalesce(v_home,'Home'),
      coalesce(v_away,'Away'),
      new.id::text
    ),
    jsonb_build_object(
      'ticket_id', new.id,
      'match_id', new.match_id,
      'status', new.status
    )
  );

  return new;
end $function$
