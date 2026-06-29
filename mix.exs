defmodule RinhaBackend2026.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_backend_2026,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {RinhaBackend2026.Application, []},
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [ci: :test]
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.18"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      ci: ["format --check-formatted", "test"]
    ]
  end
end
