CREATE POLICY matches_read_all ON public.matches FOR SELECT TO public USING (true);
CREATE POLICY onboarding_insert_own ON public.onboarding_submissions FOR INSERT TO authenticated USING (true) WITH CHECK ((auth.uid() = user_id));
CREATE POLICY onboarding_select_own ON public.onboarding_submissions FOR SELECT TO authenticated USING ((auth.uid() = user_id));
CREATE POLICY profiles_insert_own ON public.profiles FOR INSERT TO authenticated USING (true) WITH CHECK ((auth.uid() = user_id));
CREATE POLICY profiles_select_own ON public.profiles FOR SELECT TO authenticated USING ((auth.uid() = user_id));
CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));
CREATE POLICY answers_insert_own ON public.ticket_answers FOR INSERT TO authenticated USING (true) WITH CHECK ((EXISTS ( SELECT 1
   FROM tickets t
  WHERE ((t.id = ticket_answers.ticket_id) AND (t.user_id = auth.uid())))));
CREATE POLICY answers_select_own ON public.ticket_answers FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM tickets t
  WHERE ((t.id = ticket_answers.ticket_id) AND (t.user_id = auth.uid())))));
CREATE POLICY tickets_insert_own ON public.tickets FOR INSERT TO authenticated USING (true) WITH CHECK ((auth.uid() = user_id));
CREATE POLICY tickets_select_own ON public.tickets FOR SELECT TO authenticated USING ((auth.uid() = user_id));
CREATE POLICY "Users can insert own data" ON public.users FOR INSERT TO public USING (true) WITH CHECK ((auth.uid() = user_id));
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE TO public USING ((auth.uid() = user_id));
CREATE POLICY "Users can view own data" ON public.users FOR SELECT TO public USING ((auth.uid() = user_id));
