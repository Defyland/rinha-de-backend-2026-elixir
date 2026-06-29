defmodule RinhaBackend2026.ScoringTest do
  use ExUnit.Case, async: true

  alias RinhaBackend2026.Scoring

  @normalization %{
    "max_amount" => 10_000.0,
    "max_installments" => 12.0,
    "amount_vs_avg_ratio" => 10.0,
    "max_minutes" => 1_440.0,
    "max_km" => 1_000.0,
    "max_tx_count_24h" => 20.0,
    "max_merchant_avg_amount" => 10_000.0
  }

  @mcc_risk %{"5411" => 0.15, "7802" => 0.75}

  test "vectorizes the official legit example" do
    assert {:ok, vector} = Scoring.vectorize(legit_payload(), @normalization, @mcc_risk)

    expected = [
      0.004112,
      0.16666666666666666,
      0.05,
      0.782608695652174,
      0.3333333333333333,
      -1.0,
      -1.0,
      0.0292331036248,
      0.15,
      0.0,
      1.0,
      0.0,
      0.15,
      0.006025
    ]

    Enum.zip(vector, expected)
    |> Enum.each(fn {actual, expected_value} ->
      assert abs(actual - expected_value) < 0.0005
    end)
  end

  test "vectorizes the official fraud example" do
    payload = %{
      "id" => "tx-3330991687",
      "transaction" => %{
        "amount" => 9505.97,
        "installments" => 10,
        "requested_at" => "2026-03-14T05:15:12Z"
      },
      "customer" => %{
        "avg_amount" => 81.28,
        "tx_count_24h" => 20,
        "known_merchants" => ["MERC-008", "MERC-007", "MERC-005"]
      },
      "merchant" => %{
        "id" => "MERC-068",
        "mcc" => "7802",
        "avg_amount" => 54.86
      },
      "terminal" => %{
        "is_online" => false,
        "card_present" => true,
        "km_from_home" => 952.27
      },
      "last_transaction" => nil
    }

    assert {:ok, vector} = Scoring.vectorize(payload, @normalization, @mcc_risk)

    expected = [
      0.950597,
      0.8333333333333334,
      1.0,
      0.21739130434782608,
      0.8333333333333334,
      -1.0,
      -1.0,
      0.95227,
      1.0,
      0.0,
      1.0,
      1.0,
      0.75,
      0.005486
    ]

    Enum.zip(vector, expected)
    |> Enum.each(fn {actual, expected_value} ->
      assert abs(actual - expected_value) < 0.0005
    end)
  end

  test "scores against a small exact knn dataset" do
    state = %{
      normalization: @normalization,
      mcc_risk: @mcc_risk,
      references: [
        %{vector: List.duplicate(0.0, 14), label: "legit"},
        %{vector: List.duplicate(0.01, 14), label: "legit"},
        %{vector: List.duplicate(0.02, 14), label: "legit"},
        %{vector: List.duplicate(0.03, 14), label: "fraud"},
        %{vector: List.duplicate(0.04, 14), label: "fraud"}
      ]
    }

    assert {:ok, %{approved: true, fraud_score: 0.4}} = Scoring.score(legit_payload(), state)
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
