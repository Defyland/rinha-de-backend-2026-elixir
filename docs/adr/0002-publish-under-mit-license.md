# ADR 0002: Publish the Repository Under the MIT License

## Context

This repository is already a public, runnable Elixir baseline for the Rinha
2026 fraud-scoring contract. Without an explicit license, the executable OTP
reference is visible but still legally ambiguous to reuse.

## Options considered

1. Keep the default all-rights-reserved posture.
2. Publish under the MIT License.
3. Delay licensing until ANN or memory-compaction work exists.

## Chosen option

Option 2: publish under the MIT License.

## Pros

- Learners can reuse the OTP baseline, docs, and verification notes with a
  standard permissive license.
- The public repository now matches its didactic intent.

## Cons

- Forks may reuse the baseline without carrying the same performance caveats.

## Consequences

- The repo remains a correctness-first Elixir reference build.
- Future optimization loops can start from an explicitly reusable public base.
