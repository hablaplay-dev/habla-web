ALTER TABLE public.onboarding_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY onboarding_insert_own ON public.onboarding_submissions FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));
CREATE POLICY onboarding_select_own ON public.onboarding_submissions FOR SELECT TO authenticated USING ((auth.uid() = user_id));
