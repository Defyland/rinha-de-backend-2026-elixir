# Rinha de Backend 2026 Elixir

[![CI](https://github.com/Defyland/rinha-de-backend-2026-elixir/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Defyland/rinha-de-backend-2026-elixir/actions/workflows/ci.yml)

Elixir/OTP reference slice for the [Rinha de Backend 2026](https://github.com/zanfranceschi/rinha-de-backend-2026) fraud-scoring challenge.

This repository no longer stops at bootstrap notes. It now provides:

- the real `GET /ready` and `POST /fraud-score` contract on port `9999`
- official 14-dimension vectorization
- exact `k=5` Euclidean neighbor search
- a supervised reference index process
- challenge-shaped `docker-compose.yml` with Nginx + two API instances
- ADR, architecture notes, tests, CI, OpenAPI, and sample resources

This is a **correctness-first baseline**, not a claim of final competition performance. It is public-ready because it is honest about what works today and what still needs to happen before the memory and p99 envelope is competitive.

## What this project is for

The challenge is a fraud API backed by vector search over 3 million labeled references. This repo proves the core Elixir systems story first:

- deterministic vectorization from the official rules
- supervised startup that loads scoring resources once
- exact scoring behavior behind a very small HTTP surface
- runnable local topology that mirrors the official load-balancer requirement

## Runtime shape

- `RinhaBackend2026.Application`: OTP entrypoint
- `RinhaBackend2026.ReferenceIndex`: supervised process that loads normalization, MCC risk, and references
- `RinhaBackend2026.Scoring`: pure vectorization and exact k-NN logic
- `RinhaBackend2026Web.Router`: Plug/Bandit HTTP surface

Supporting docs:

- [docs/architecture/overview.md](docs/architecture/overview.md)
- [docs/adr/0001-exact-knn-baseline.md](docs/adr/0001-exact-knn-baseline.md)
- [docs/verification/vectorization-proof.md](docs/verification/vectorization-proof.md)
- [docs/verification/supervision-restart-proof.md](docs/verification/supervision-restart-proof.md)

## How to run in 5 minutes

1. Start the API with the bundled sample references:

```bash
mix setup
mix run --no-halt
```

2. Check readiness:

```bash
curl -s http://127.0.0.1:9999/ready
```

3. Score the official legit example:

```bash
curl -s http://127.0.0.1:9999/fraud-score \
  -H 'content-type: application/json' \
  --data @docs/examples/legit-request.json
```

4. Run the verification loop:

```bash
mix format --check-formatted
mix test
```

5. Run the load-balanced local topology:

```bash
docker compose up --build
```

## Official resources

This repo vendors the review-friendly assets:

- `resources/normalization.json`
- `resources/mcc_risk.json`
- `resources/example-references.json`

To fetch the official 3-million-reference dataset:

```bash
./scripts/fetch-official-resources.sh
```

Then run against it:

```bash
RINHA_REFERENCES_PATH=resources/references.json.gz mix run --no-halt
```

## API contract

The local OpenAPI mirror lives in [openapi.yaml](openapi.yaml).

`GET /ready`
- returns `200` once the supervised reference index has loaded its resources

`POST /fraud-score`
- accepts the official payload shape
- returns:

```json
{
  "approved": true,
  "fraud_score": 0.2
}
```

## Evaluation posture

What already works:

- exact vectorization from the official rules
- exact `k=5` neighbor scoring
- OTP-supervised resource loading
- gzip or JSON resource loading
- request tests for readiness and scoring
- local challenge-shaped topology

What is intentionally still not final:

- naive full-dataset loading is too memory-expensive for a serious two-instance submission
- brute-force exact search still needs benchmark evidence before p99 claims
- no ANN index, quantized representation, or compact binary preload yet

## Key trade-offs

- **Correctness before approximation**: exact k-NN keeps the first slice easy to validate.
- **OTP where it matters**: resource loading lives in a supervised process, not in ad hoc module state.
- **Honest deployment story**: `docker-compose.yml` demonstrates the topology requirement, but this baseline should be treated as a public reference build rather than a final scoring build.

## Files reviewers should read first

- [docs/architecture/overview.md](docs/architecture/overview.md)
- [docs/adr/0001-exact-knn-baseline.md](docs/adr/0001-exact-knn-baseline.md)
- [docs/verification/vectorization-proof.md](docs/verification/vectorization-proof.md)
- [docs/verification/supervision-restart-proof.md](docs/verification/supervision-restart-proof.md)
- [docs/examples/legit-request.json](docs/examples/legit-request.json)
- [docs/examples/fraud-request.json](docs/examples/fraud-request.json)
