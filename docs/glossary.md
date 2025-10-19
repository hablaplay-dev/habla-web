# Glosario (Habla!)

**Lukas**: moneda in-app. Se compra con dinero real y se usa para comprar Combinadas y canjear en la Tienda.

**Combinada**: ticket de predicciones que el jugador compra para un **partido específico**. Se guarda en `tickets` y sus respuestas en `ticket_answers`.

**Ranking en vivo**: tabla `ticket_scores_live` con `points` por ticket durante el partido. Se recalcula por eventos del encuentro.

**Cierre**: al finalizar el partido, se guarda el resultado en `match_results` y se consolida en `ticket_scores`. Se reparte el bote a **top-3**.

**Bote por partido**: suma de Lukas gastados en Combinadas para ese partido menos el rake. (Pendiente: tabla de liquidación por partido.)

**Perfil**: datos públicos del usuario en `profiles` (ej. `username`, `avatar_url`).

**RPC**: función SQL expuesta por Supabase vía HTTP. Se versionan en `supabase/schema/functions/`.

**Edge Function**: función TypeScript/deno desplegada en Supabase para integrar APIs externas o tareas server-side.

**Ledger**: libro de movimientos de Lukas (depósitos, débitos por tickets, premios, canjes). Pendiente de modelar (`lukas_ledger`, `lukas_balance`).

**Tienda**: catálogo de premios canjeables con Lukas (`store_items`, `store_redemptions`).
