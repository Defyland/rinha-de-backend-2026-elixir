defmodule RinhaBackend2026.ReferenceIndexTest do
  use ExUnit.Case, async: true

  alias RinhaBackend2026.ReferenceIndex

  test "loads resources under supervision and reports readiness" do
    name = Module.concat(__MODULE__, Index)

    start_supervised!(
      {ReferenceIndex,
       name: name,
       resource_paths: %{
         normalization: "resources/normalization.json",
         mcc_risk: "resources/mcc_risk.json",
         references: "resources/example-references.json"
       }}
    )

    status = ReferenceIndex.ready_status(name)

    assert status.status == "ok"
    assert status.references_loaded >= 5
  end
end
