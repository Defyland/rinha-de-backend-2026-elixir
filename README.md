# rinha-de-backend-2026-elixir

Bootstrap Elixir para a Rinha de Backend 2026.

Referencia oficial: https://github.com/zanfranceschi/rinha-de-backend-2026

Escopo atual:
- Apenas inicializacao do repositorio local.
- Sem implementacao de endpoints, deteccao de fraude, busca vetorial, containers, benchmarks ou submissao.
- Sem remote e sem commit inicial.

Regras principais registradas para a proxima etapa:
- O desafio e uma API de deteccao de fraude com busca vetorial.
- A API final deve expor `GET /ready` e `POST /fraud-score` na porta `9999`.
- A solucao final deve ter load balancer e duas instancias da API.
- A submissao final deve respeitar `docker-compose.yml`, rede `bridge`, imagens `linux-amd64` e limite agregado de 1 CPU e 350 MB.

Proxima etapa:
1. Ler `docs/br/API.md`, `REGRAS_DE_DETECCAO.md`, `DATASET.md`, `ARQUITETURA.md` e `AVALIACAO.md`.
2. Definir a arquitetura Elixir antes de implementar qualquer endpoint.

