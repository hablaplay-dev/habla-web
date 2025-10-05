ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
CREATE POLICY matches_read_all ON public.matches FOR SELECT TO public USING (true);
