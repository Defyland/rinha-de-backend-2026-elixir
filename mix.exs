defmodule RinhaBackend2026.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_backend_2026,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end
end

