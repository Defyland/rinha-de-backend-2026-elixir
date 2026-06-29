defmodule RinhaBackend2026.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {RinhaBackend2026.ReferenceIndex, []}
      ] ++ server_children()

    Supervisor.start_link(children, strategy: :one_for_one, name: RinhaBackend2026.Supervisor)
  end

  defp server_children do
    if Application.get_env(:rinha_backend_2026, :server, true) do
      [
        {Bandit,
         plug: RinhaBackend2026Web.Router,
         scheme: :http,
         port: RinhaBackend2026.Config.port(),
         startup_log: false}
      ]
    else
      []
    end
  end
end
