# Architecture Overview

## Context

The official challenge requires:

- `GET /ready`
- `POST /fraud-score`
- vectorization with 14 published dimensions
- nearest-neighbor search against 3 million labeled references
- one load balancer and at least two API instances on port `9999`

This repository implements the smallest complete Elixir slice that proves those rules honestly.

## Current runtime shape

```text
client
  -> nginx load balancer (:9999)
      -> api-1 (Bandit + Plug + OTP)
      -> api-2 (Bandit + Plug + OTP)
```

Each API instance boots:

- a supervised `ReferenceIndex` process
- loaded normalization and MCC-risk tables
- a reference dataset from JSON or gzip-compressed JSON

## Request flow

1. Plug receives `POST /fraud-score`.
2. `ReferenceIndex` delegates to pure scoring logic.
3. The payload becomes the official 14-dimension vector.
4. The engine performs exact k-NN with Euclidean distance.
5. The response returns `approved` and `fraud_score`.

## Why OTP matters here

The first systems signal for Elixir is not adding process theater everywhere. It is putting the long-lived load-bearing state in a supervised process:

- resource loading happens once at startup
- readiness reflects actual scoring-state availability
- future loops can swap the exact in-memory representation without changing the HTTP contract

## Operational limits

This baseline is correct but not yet final for the competition envelope:

- naive full-dataset loading is still memory-heavy with two API containers
- exact search still needs benchmark evidence before any p99 claim

The next loop should focus on compact index preparation, benchmark capture, and memory budgeting rather than changing the already-proven contract.
