ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own data" ON public.users FOR INSERT TO public WITH CHECK ((auth.uid() = user_id));
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE TO public USING ((auth.uid() = user_id));
CREATE POLICY "Users can view own data" ON public.users FOR SELECT TO public USING ((auth.uid() = user_id));
