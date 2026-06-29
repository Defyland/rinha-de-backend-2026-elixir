# ADR 0001: Start With An Exact k-NN Baseline

## Context

The repository started as an uncommitted bootstrap with no executable API, no OTP supervision story, and no proof that the official Rinha 2026 contract was implemented correctly.

The first public-ready loop needed to establish:

- the HTTP contract
- the vectorization rules
- the scoring behavior
- a minimal but real OTP runtime shape

## Options considered

1. Build an ANN index immediately.
2. Build an exact baseline first, then optimize.
3. Stop at documentation.

## Chosen option

Option 2: build an exact baseline first.

## Pros

- Easy to validate from the official examples.
- Keeps the first Elixir runtime small and reviewable.
- Creates a correctness baseline before introducing approximation or compaction.
- Lets later performance work change one concern at a time.

## Cons

- Full-dataset exact search is not submission-ready.
- Two full in-memory indexes will stress the challenge memory budget.

## Consequences

- The repo is now executable and reviewable.
- The OTP story is real but still lean: one supervised reference index plus the HTTP server.
- The next improvement loop should focus on compact indexing, benchmark evidence, and p99 tuning rather than changing request semantics.

## Verification evidence

- `mix format --check-formatted`
- `mix test`
- `docker compose config`
