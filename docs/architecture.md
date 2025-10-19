# Arquitectura y flujos

## Diagrama (alto nivel)

```mermaid
flowchart LR
  A[Usuario (Web/App)] -->|Auth| B[(Supabase Auth)]
  A -->|Compra Lukas| P[Proveedor de pagos externo]
  P -->|Webhook/Confirmación| L[(Ledger Lukas)*]
  A -->|Comprar Combinada| T[(tickets, ticket_answers)]
  A -->|Ver ranking live| SL[(ticket_scores_live)]
  E[API-Football] -->|sync/cron/webhook| F[Edge Function: sync-fixture*]
  F -->|actualiza| M[(matches, match_results)]
  F -->|recalcula| SL
  M -->|cierre| S[(ticket_scores)]
  A -->|Canje tienda| ST[Store*]
  style L fill:#eef,stroke:#99f,stroke-width:1px
  style ST fill:#eef,stroke:#99f,stroke-width:1px
