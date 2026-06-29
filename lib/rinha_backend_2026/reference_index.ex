defmodule RinhaBackend2026.ReferenceIndex do
  @moduledoc false

  use GenServer

  alias RinhaBackend2026.{Config, Scoring}

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def score(payload, server \\ __MODULE__) do
    GenServer.call(server, {:score, payload})
  end

  def ready_status(server \\ __MODULE__) do
    GenServer.call(server, :ready_status)
  end

  @impl true
  def init(opts) do
    resource_paths = Keyword.get(opts, :resource_paths, Config.resource_paths())
    state = Scoring.load_resources!(resource_paths)

    {:ok, state}
  end

  @impl true
  def handle_call(:ready_status, _from, state) do
    {:reply,
     %{
       status: "ok",
       references_loaded: length(state.references),
       reference_source: state.reference_source
     }, state}
  end

  def handle_call({:score, payload}, _from, state) do
    {:reply, Scoring.score(payload, state), state}
  end
end
