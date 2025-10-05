ALTER TABLE public.ticket_answers ENABLE ROW LEVEL SECURITY;
CREATE POLICY answers_insert_own ON public.ticket_answers FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM tickets t
  WHERE ((t.id = ticket_answers.ticket_id) AND (t.user_id = auth.uid())))));
CREATE POLICY answers_select_own ON public.ticket_answers FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM tickets t
  WHERE ((t.id = ticket_answers.ticket_id) AND (t.user_id = auth.uid())))));
