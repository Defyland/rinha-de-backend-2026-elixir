defmodule RinhaBackend2026.ReferenceIndexTest do
  use ExUnit.Case, async: true

  alias RinhaBackend2026.ReferenceIndex

  test "loads resources under supervision and reports readiness" do
    name = Module.concat(__MODULE__, Index)

    start_supervised!({ReferenceIndex, name: name, resource_paths: resource_paths()})

    status = ReferenceIndex.ready_status(name)

    assert status.status == "ok"
    assert status.references_loaded >= 5
  end

  test "restarts after a crash and preserves scoring behavior" do
    name = Module.concat(__MODULE__, RestartingIndex)

    pid =
      start_supervised!(
        {ReferenceIndex, name: name, notify: self(), resource_paths: resource_paths()}
      )

    assert_receive {:reference_index_ready, ^pid}

    ref = Process.monitor(pid)
    Process.exit(pid, :kill)

    assert_receive {:DOWN, ^ref, :process, ^pid, :killed}
    assert_receive {:reference_index_ready, restarted_pid}
    refute restarted_pid == pid

    status = ReferenceIndex.ready_status(name)

    assert status.status == "ok"
    assert status.references_loaded >= 5

    assert {:ok, result} = ReferenceIndex.score(legit_payload(), name)
    assert result.approved == true
    assert_in_delta result.fraud_score, 0.0, 1.0e-9
  end

  defp resource_paths do
    %{
      normalization: "resources/normalization.json",
      mcc_risk: "resources/mcc_risk.json",
      references: "resources/example-references.json"
    }
  end

  defp legit_payload do
    %{
      "id" => "tx-1329056812",
      "transaction" => %{
        "amount" => 41.12,
        "installments" => 2,
        "requested_at" => "2026-03-11T18:45:53Z"
      },
      "customer" => %{
        "avg_amount" => 82.24,
        "tx_count_24h" => 3,
        "known_merchants" => ["MERC-003", "MERC-016"]
      },
      "merchant" => %{
        "id" => "MERC-016",
        "mcc" => "5411",
        "avg_amount" => 60.25
      },
      "terminal" => %{
        "is_online" => false,
        "card_present" => true,
        "km_from_home" => 29.2331036248
      },
      "last_transaction" => nil
    }
  end
end
