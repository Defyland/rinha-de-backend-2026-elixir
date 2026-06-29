# Vectorization Proof

This repository now includes executable proof for the two worked examples published in the official Rinha 2026 fraud-detection rules.

What is proved:

- the legit example vector matches the published 14-dimension result
- the fraud example vector matches the published 14-dimension result
- the implementation preserves the `-1` sentinel when `last_transaction` is absent

What is not claimed:

- final challenge accuracy against the full 3-million-reference dataset
- submission-grade latency under the official CPU and memory envelope

Why this matters:

- it validates the contract before any ANN or memory-compaction work
- it gives reviewers direct executable evidence that the rule translation is correct

Run:

```bash
mix test test/rinha_backend_2026/scoring_test.exs
```
