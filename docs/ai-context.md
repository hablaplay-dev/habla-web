# AI Context — Habla!

Este documento resume la app para asistentes tipo “Codex/ChatGPT”:

**Qué es:**  
Juego de predicciones de fútbol con moneda in-app (**Lukas**) y tickets de **Combinadas**. Cada partido genera un bote y un **ranking en vivo**; al terminar, el **top-3** se lleva el bote. Los usuarios también **canjean Lukas** en una tienda.

**Objetivo del repo:**  
Ser el **fuente de verdad** del front y del backend lógico (esquema Supabase, RPC, Edge Functions) para facilitar *reasoning* de la IA, debugging y generación de parches.

**Entidades principales (BD):**
- `matches` (partidos) y `match_results` (cierre)
- `tickets`, `ticket_answers` (combinadas)
- `ticket_scores_live` (ranking live), `ticket_scores` (final)
- `profiles`, `users`, `onboarding_submissions` (perfil/auth)
- `app_config`, `email_outbox`, `seed_audit`
- `af_*` (referencia/ingesta de API-Football)

**Operativa (1–6):**
1. Registro/Login (Supabase Auth).
2. Compra de **Lukas** con dinero real (proveedor externo, ledger a definir).
3. Compra de **Combinada** (crea `tickets` + `ticket_answers`).
4. Ranking live por partido (`ticket_scores_live`).
5. Cierre y premios (top-3) → `ticket_scores`, `match_results`.
6. Canje de Lukas en tienda (modelos `store_items`, `redemptions` a definir).

**Contratos clave (ver `docs/data-contracts.md`):**
- RPC: `create_ticket`, `get_match_leaderboard`, `get_live_scores`, `close_match`, `redeem_store_item` (propuestos).
- Edge Functions: `api-football/sync-fixture`, `api-football/push-live` (propuestas).

**Cómo reproducir mínimamente:**
1) Aplicar `supabase/schema/schema.sql`.  
2) (Recomendado) Aplicar índices/constraints/funciones/rls listadas en `supabase/schema/*`.  
3) Cargar `supabase/schema/seeds/000_minimal.sql`.  
4) Abrir `index.html` y configurar `SUPABASE_URL`/`SUPABASE_ANON_KEY`.

**Problemas abiertos:**
- Ledger de **Lukas** (carga de saldo, débitos por combinada, créditos por premios y canjes), RLS y auditoría.  
- Modelos de **Tienda** (`store_items`, `redemptions`, stock).  
- Mecanismo de actualización **live** (cron, webhook o polling) y reconciliación final.

