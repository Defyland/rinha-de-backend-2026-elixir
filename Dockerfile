FROM hexpm/elixir:1.19.5-erlang-29.0.1-debian-bookworm-20250623-slim

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs ./
COPY config ./config

RUN mix deps.get

COPY lib ./lib
COPY resources ./resources
COPY openapi.yaml ./openapi.yaml

RUN MIX_ENV=prod mix compile

ENV PORT=9999

EXPOSE 9999

CMD ["mix", "run", "--no-halt"]
