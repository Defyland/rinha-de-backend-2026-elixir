# Supervision Restart Proof

This repository now proves a concrete OTP claim instead of only describing it.

What is exercised:

- `RinhaBackend2026.ReferenceIndex` boots under supervision
- the process can crash abnormally
- the supervisor restarts it automatically
- readiness and scoring behavior remain available after restart

Why this matters:

- the repo claims an OTP-supervised scoring service, not just a synchronous function library
- restart behavior is one of the core reasons to choose this Elixir shape over ad hoc module state

Trade-off:

- the current service keeps restart scope intentionally small: only the reference index is stateful and supervised
- richer worker pools or load-shedding layers are deferred until the repo moves from correctness baseline to performance-focused challenge optimization

Run:

```bash
mix test test/rinha_backend_2026/reference_index_test.exs
```
