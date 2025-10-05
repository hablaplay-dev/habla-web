CREATE TABLE public.ticket_answers (
  id bigint DEFAULT nextval('ticket_answers_id_seq'::regclass) NOT NULL,
  ticket_id bigint NOT NULL,
  q_key text NOT NULL,
  value text NOT NULL
);
