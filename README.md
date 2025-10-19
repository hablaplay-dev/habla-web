# Habla! — Juego de combinadas de fútbol con “Lukas”

Habla! es una app de predicciones de fútbol donde los jugadores:
1) se registran/inician sesión,
2) compran **Lukas** (moneda in-app),
3) usan sus Lukas para adquirir **Combinadas** (tickets con predicciones),
4) compiten por **pozos por partido** con un **ranking en vivo**,
5) al finalizar, el **top 3** se lleva el bote acumulado,
6) y pueden **canjear Lukas** por premios en una tienda virtual.

Este repo es el **fuente de verdad** del front web y del backend lógico en Supabase (esquema, funciones RPC, edge functions). Está pensado para que pueda ser leído por asistentes tipo “Codex/ChatGPT”.

---

## Estructura del repositorio
.
├─ index.html # Front actual (estático)
├─ supabase/
│ └─ schema/
│ ├─ schema.sql # DDL base de tablas (desde Supabase Visualizer)
│ ├─ indexes/ # (añadir) índices
│ ├─ constraints/ # (añadir) PK/FK/UNIQUE/CHECK
│ ├─ sequences/ # (añadir) OWNED BY de secuencias
│ ├─ views/ # (añadir) vistas
│ ├─ functions/ # (añadir) funciones / RPC
│ ├─ triggers/ # (añadir) triggers
│ ├─ extensions/ # (añadir) extensiones (pgcrypto, etc.)
│ ├─ grants/ # (añadir) GRANTs
│ ├─ rls/ # (añadir) enable/force + policies
│ │ ├─ enable_force.sql
│ │ └─ policies/
│ └─ seeds/ # (añadir) inserts mínimos reproducibles
│ └─ edge-functions/
│ └─ api-football/
│ └─ index.ts
├─ docs/
│ ├─ ai-context.md
│ ├─ architecture.md
│ ├─ data-contracts.md
│ ├─ env.example
│ └─ glossary.md
└─ README.md

> **Nota:** si hoy solo tienes `schema.sql`, puedes ir completando las subcarpetas con el material SQL que extraigas desde el **SQL Editor** de Supabase (sin CLI). En `docs/architecture.md` tienes consultas listas para copiar/pegar y versionar índices, constraints, funciones, RLS, etc.

---

## Setup rápido (sin CLI)

1. **Variables de entorno**  
   Copia `docs/env.example` y completa valores en **Vercel** y en **Supabase (Edge Functions / Auth / Storage)**. No commitees secretos reales.

2. **Provisionar BD en Supabase Studio** (orden recomendado):  
   1) `supabase/schema/extensions/*.sql`  
   2) `supabase/schema/schema.sql` (tablas)  
   3) `supabase/schema/sequences/*.sql`  
   4) `supabase/schema/constraints/*.sql` + `indexes/*.sql`  
   5) `supabase/schema/views/*.sql`  
   6) `supabase/schema/functions/*.sql` + `triggers/*.sql`  
   7) `supabase/schema/grants/*.sql`  
   8) `supabase/schema/rls/enable_force.sql` + `rls/policies/*.sql`  
   9) `supabase/schema/seeds/*.sql` (mínimo para smoke)

3. **Front web**  
   - Deploy estático en **Vercel** apuntando a la raíz o a `/` (según tu configuración).  
   - Asegúrate de exponer `SUPABASE_URL` y `SUPABASE_ANON_KEY` en las env vars del proyecto.

4. **Edge Functions (opcional, recomendado)**  
   - Versiona el fuente en `supabase/edge-functions/api-football/index.ts`.  
   - Publica manualmente desde Supabase Studio (mientras no uses CLI).

---

## Estado actual del esquema (resumen)

Tablas clave incluidas en `schema.sql`:
- `matches`, `match_results`
- `tickets`, `ticket_answers`
- `ticket_scores`, `ticket_scores_live`
- `profiles`, `onboarding_submissions`, `users`
- `app_config`, `email_outbox`, `seed_audit`
- `af_*` (ingestas/refs de API-Football)

Ver detalle en **docs/glossary.md** y contratos en **docs/data-contracts.md**.

---

## Flujo funcional (alto nivel)

- **Auth**: usuarios se registran/inician sesión (Supabase Auth).  
- **Lukas**: se compran con dinero real (proveedor de pagos externo). Se registra saldo (ledger) y transacciones (pendiente de modelar en BD, ver “Próximos pasos”).  
- **Combinada**: con Lukas, el usuario compra el ticket del partido (`tickets` + `ticket_answers`).  
- **Ranking en vivo**: `ticket_scores_live` se actualiza por eventos del partido.  
- **Cierre y premios**: al terminar, `ticket_scores` y `match_results`; top-3 se lleva el bote.  
- **Tienda**: canje de Lukas por premios (pendiente modelar: `store_items`, `redemptions`).

---

## Licencia
Privado / Uso interno del equipo de Habla!.
