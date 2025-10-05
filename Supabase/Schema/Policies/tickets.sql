ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
CREATE POLICY tickets_insert_own ON public.tickets FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));
CREATE POLICY tickets_select_own ON public.tickets FOR SELECT TO authenticated USING ((auth.uid() = user_id));
