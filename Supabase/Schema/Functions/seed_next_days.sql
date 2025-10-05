CREATE OR REPLACE FUNCTION public.seed_next_days(p_days integer DEFAULT 15, p_leagues text DEFAULT NULL::text, p_season integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  i int := 0;
  v_date text;
  v_qs   text;
begin
  if coalesce(p_days,0) < 1 then
    p_days := 1;
  end if;

  while i < p_days loop
    begin
      v_date := to_char((now() + (i || ' day')::interval), 'YYYY-MM-DD');
      v_qs   := '/api-football/seed-fixtures?date=' || v_date;

      if p_leagues is not null and p_leagues <> '' then
        v_qs := v_qs || '&league=' || p_leagues;
      end if;
      if p_season is not null then
        v_qs := v_qs || '&season=' || p_season::text;
      end if;

      -- Llamada HTTP (Edge Function). Si falla, saltamos al EXCEPTION.
      perform public.call_edge(v_qs, '{}'::jsonb);

      insert into public.seed_audit(target_date, leagues, season, ok, note)
      values ((v_date)::date, p_leagues, p_season, true, 'ok');

    exception when others then
      insert into public.seed_audit(target_date, leagues, season, ok, note)
      values ((v_date)::date, p_leagues, p_season, false, sqlerrm);
      -- No re-raise: continuamos con el siguiente día
    end;

    i := i + 1;
  end loop;
end
$function$
