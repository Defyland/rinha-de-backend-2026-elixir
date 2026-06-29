defmodule RinhaBackend2026 do
  @moduledoc """
  Public entrypoints for the challenge runtime.
  """

  alias RinhaBackend2026.ReferenceIndex

  def score(payload), do: ReferenceIndex.score(payload)
  def ready_status, do: ReferenceIndex.ready_status()
end
