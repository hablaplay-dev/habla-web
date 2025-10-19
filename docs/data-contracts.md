```markdown
# Data Contracts (RPC & Edge)

> Nota: varios endpoints están **propuestos** para guiar el desarrollo y para que la IA (Codex) genere parches consistentes. Ajusta los nombres a tus funciones reales conforme las vayas versionando en `supabase/schema/functions/`.

---

## Autenticación (Supabase Auth)
- **Registro/Login**: Magic link / Email+Password / OAuth (según config).  
- **Perfil**: `profiles` (metadatos públicos, ej. `username`, `avatar_url`).

---

## Lukas (propuesto)

> Falta modelado de ledger; sugerencia mínima:

- `lukas_ledger(id, user_id, type, amount, ref, created_at)`  
  - `type ∈ {deposit, ticket_purchase, prize_credit, store_redeem, adjustment}`
- `lukas_balance(user_id, balance)`

**RPC propuesto**: `lukas_get_balance()`  
**Response**
```json
{ "balance": 1250 }
