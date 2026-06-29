defmodule RinhaBackend2026Web.RouterTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias RinhaBackend2026Web.Router

  test "GET /ready returns readiness metadata" do
    conn =
      :get
      |> conn("/ready")
      |> Router.call([])

    assert conn.status == 200

    assert %{"status" => "ok", "references_loaded" => references_loaded} =
             Jason.decode!(conn.resp_body)

    assert references_loaded >= 5
  end

  test "POST /fraud-score returns a decision payload" do
    conn =
      :post
      |> conn("/fraud-score", legit_payload())
      |> put_req_header("content-type", "application/json")
      |> Router.call([])

    assert conn.status == 200
    payload = Jason.decode!(conn.resp_body)

    assert payload["approved"] == true
    assert_in_delta payload["fraud_score"], 0.0, 1.0e-9
  end

  defp legit_payload do
    Jason.encode!(%{
      id: "tx-1329056812",
      transaction: %{
        amount: 41.12,
        installments: 2,
        requested_at: "2026-03-11T18:45:53Z"
      },
      customer: %{
        avg_amount: 82.24,
        tx_count_24h: 3,
        known_merchants: ["MERC-003", "MERC-016"]
      },
      merchant: %{
        id: "MERC-016",
        mcc: "5411",
        avg_amount: 60.25
      },
      terminal: %{
        is_online: false,
        card_present: true,
        km_from_home: 29.2331036248
      },
      last_transaction: nil
    })
  end
end
