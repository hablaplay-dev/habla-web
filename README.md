# Habla! — Web & Supabase Schema

Este repositorio contiene el **front web** de Habla! y la **línea base del esquema** de base de datos en Supabase. El objetivo es que cualquier persona (o asistente/IA como ChatGPT/Codex) pueda entender, auditar y reproducir el proyecto sin depender del Dashboard de Supabase.

## Estructura
.
├─ index.html
├─ Supabase/
│ └─ Schema/
│ └─ schema.sql # DDL base: tablas principales (matches, tickets, etc.)
└─ docs/
├─ ai-context.md
├─ architecture.md
├─ data-contracts.md
├─ env.example
└─ glossary.md

> **Nota:** Más adelante se recomienda migrar a minúsculas con `supabase/` y subdividir el esquema en carpetas (`functions/`, `indexes/`, `constraints/`, `rls/`, `seeds/`, etc.). Por ahora, este repo incluye la línea base (`schema.sql`) y documentación completa en `docs/`.

## Cómo correr el front (estático)

1. Abre `index.html` en tu navegador, o sirve la carpeta con cualquier servidor estático.
2. Configura las variables de entorno (ver `docs/env.example`) donde corresponda (Vercel para producción).

## Cómo aplicar el esquema en Supabase (manual, sin CLI)

1. Entra a **Supabase Studio → SQL Editor**.  
2. Copia el contenido de `Supabase/Schema/schema.sql` y ejecútalo en tu proyecto.  
3. (Opcional en el futuro) Aplica objetos adicionales por carpetas: `functions/`, `rls/`, `indexes/`, `constraints/`, `views/`, `grants/`, `seeds/`.

## Orden de aplicación recomendado (cuando se separen archivos)

1. `extensions/`  
2. `schema.sql` (tablas)  
3. `sequences/` (OWNED BY)  
4. `constraints/` + `indexes/`  
5. `views/` (y `matviews/` si existieran)  
6. `functions/` + `triggers/`  
7. `grants/`  
8. `rls/enable_force.sql` + `rls/policies/`  
9. `seeds/`

## Enlaces útiles

- Documentación del proyecto: carpeta [`docs/`](./docs).
- Contratos de datos (RPC/Edge/API): [`docs/data-contracts.md`](./docs/data-contracts.md).
- Contexto para IA (cómo “leer” el repo): [`docs/ai-context.md`](./docs/ai-context.md).

## Licencia

Privado / Uso interno del equipo de Habla!.
