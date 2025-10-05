CREATE TRIGGER trg_tsl_touch CREATE TRIGGER trg_tsl_touch BEFORE UPDATE ON public.ticket_scores_live FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_ticket_email CREATE TRIGGER trg_ticket_email AFTER INSERT ON public.tickets FOR EACH ROW EXECUTE FUNCTION enqueue_ticket_email();
CREATE TRIGGER trg_tickets_email_outbox CREATE TRIGGER trg_tickets_email_outbox AFTER INSERT ON public.tickets FOR EACH ROW EXECUTE FUNCTION enqueue_ticket_email();
CREATE TRIGGER update_users_updated_at CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
