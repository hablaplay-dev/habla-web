# AI Context — Cómo una IA debe leer este repo

**Objetivo del producto (10 líneas):**  
Habla! es un juego de predicciones de fútbol para Perú. Los usuarios envían “tickets” con picks simples (p. ej., 1X2, BTTS, Over 2.5) para 1 partido en particular donde compiten entre sí en un torneo. Para participar en el torneo de cada partido pagan su entrada y se arma el bote de premios que luego es repartido entre los 3 primeros puestos. La app es freemium y usa “Lukas” como moneda interna para canjes de recompensas en una tienda interna. El backend vive en **Supabase**; el front actual es un sitio estático (`index.html`). Se integra con **API-Football** vía funciones o edge functions (no versionadas aquí todavía). Este repo ofrece el **DDL base** (tablas clave) y documentación de **contratos** para que una IA pueda proponer cambios de forma segura.

**Qué hay en este repo hoy:**  
- `index.html` (front estático).  
- `Supabase/Schema/schema.sql` con tablas principales (`matches`, `tickets`, `ticket_answers`, `ticket_scores_live`, `af_*` para fixtures/teams/leagues, etc.).  
- `docs/` con arquitectura, contratos de datos, glosario y variables de entorno.

**Suposiciones actuales (para la IA):**
- Aún no se han versionado funciones/RPC/policies/índices en carpetas separadas.  
- Edge Functions (API-Football) viven todavía en el Dashboard de Supabase.  
- El orden de ejecución del esquema debe respetarse (ver README).  
- No se usa CLI; todo es **manual** desde el SQL Editor.

**Flujo de alto nivel (usuario → puntos → ranking → rewards):**
1. Usuario crea/enruta perfil (opcional) y envía un **ticket** para un **match** pagando su costo de **ticket**.  
2. El ticket guarda **respuestas** (`ticket_answers`).  
3. Una rutina (función o edge) calcula **scores** live (`ticket_scores_live`) y finales (`ticket_scores`).  
4. Según ranking de puntos del **match** se premia a los 3 primeros puestos con el bote de premios acumulado por el costo de los tickets para ese partido.  
5. El usuario canjea “Lukas” por recompensas (catálogo por definir).

**Qué puede pedir la IA con seguridad:**
- Agregar campos/índices documentando el impacto.  
- Generar vistas para leaderboard.  
- Proponer RLS/policies típicas (`auth.uid() = user_id`).  
- Diseñar seeds mínimos para smoke tests.  
- Escribir funciones puras (consultas de lectura) sobre las tablas existentes.

**Qué debe evitar la IA sin confirmación:**
- Cambios destructivos (DROP/ALTER) que rompan compatibilidad.  
- Escribir secretos en el repo.  
- Suponer contratos externos no listados en `docs/data-contracts.md`, los cambios deben ser sugeridos.

**Cómo reproducir un smoke test (manual):**
- Crea tablas con `schema.sql`.  
- Inserta 1 liga, 1 match, 1 usuario y 1 ticket + answers (cuando existan seeds).  
- Ejecuta una consulta de ranking simple (vista propuesta o SELECT) y verifica resultados.

Mermaid — vista simple del flujo
graph LR
A[Usuario] --> B[Ticket]
B --> C[Ticket Answers]
C --> D((Scoring Live))
D --> E[Ticket Scores Final]
E --> F[Rewards (Lukas)]
