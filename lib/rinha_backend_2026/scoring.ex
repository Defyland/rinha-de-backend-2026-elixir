defmodule RinhaBackend2026.Scoring do
  @moduledoc false

  @vector_dimensions 14
  @neighbor_count 5

  def load_resources!(resource_paths) do
    normalization = read_json!(resource_paths.normalization)
    mcc_risk = read_json!(resource_paths.mcc_risk)

    references =
      resource_paths.references
      |> read_json!()
      |> Enum.map(&normalize_reference!/1)

    if references == [] do
      raise ArgumentError, "reference dataset is empty"
    end

    %{
      normalization: normalization,
      mcc_risk: mcc_risk,
      references: references,
      reference_source: resource_paths.references
    }
  end

  def score(payload, state) do
    with {:ok, vector} <- vectorize(payload, state.normalization, state.mcc_risk) do
      nearest =
        state.references
        |> Enum.map(fn %{vector: reference_vector, label: label} ->
          {squared_distance(vector, reference_vector), label}
        end)
        |> Enum.sort_by(&elem(&1, 0))
        |> Enum.take(min(@neighbor_count, length(state.references)))

      fraud_neighbors =
        Enum.count(nearest, fn {_distance, label} -> label == "fraud" end)

      fraud_score = fraud_neighbors / length(nearest)

      {:ok, %{approved: fraud_score < 0.6, fraud_score: fraud_score}}
    end
  end

  def vectorize(payload, normalization, mcc_risk) do
    with {:ok, requested_at, _offset} <-
           DateTime.from_iso8601(payload["transaction"]["requested_at"]),
         {:ok, minutes_since_last_tx, km_from_last_tx} <-
           last_transaction_features(payload["last_transaction"], requested_at) do
      amount = payload["transaction"]["amount"]
      customer_avg = payload["customer"]["avg_amount"]

      amount_vs_avg =
        if customer_avg <= 0 do
          1.0
        else
          clamp(amount / customer_avg / normalization["amount_vs_avg_ratio"])
        end

      unknown_merchant =
        if payload["merchant"]["id"] in payload["customer"]["known_merchants"], do: 0.0, else: 1.0

      {:ok,
       [
         clamp(amount / normalization["max_amount"]),
         clamp(payload["transaction"]["installments"] / normalization["max_installments"]),
         amount_vs_avg,
         requested_at.hour / 23,
         (Date.day_of_week(DateTime.to_date(requested_at), :monday) - 1) / 6,
         minutes_since_last_tx,
         km_from_last_tx,
         clamp(payload["terminal"]["km_from_home"] / normalization["max_km"]),
         clamp(payload["customer"]["tx_count_24h"] / normalization["max_tx_count_24h"]),
         bool_as_unit(payload["terminal"]["is_online"]),
         bool_as_unit(payload["terminal"]["card_present"]),
         unknown_merchant,
         Map.get(mcc_risk, payload["merchant"]["mcc"], 0.5),
         clamp(payload["merchant"]["avg_amount"] / normalization["max_merchant_avg_amount"])
       ]}
    else
      {:error, :invalid_format} ->
        {:error, "invalid timestamp format"}
    end
  end

  defp last_transaction_features(nil, _requested_at), do: {:ok, -1.0, -1.0}

  defp last_transaction_features(last_transaction, requested_at) do
    with {:ok, last_requested_at, _offset} <- DateTime.from_iso8601(last_transaction["timestamp"]) do
      minutes =
        requested_at
        |> DateTime.diff(last_requested_at, :minute)
        |> max(0)

      {:ok, clamp(minutes / 1440), clamp(last_transaction["km_from_current"] / 1000)}
    else
      {:error, _reason} -> {:error, :invalid_format}
    end
  end

  defp normalize_reference!(%{"vector" => vector, "label" => label})
       when length(vector) == @vector_dimensions do
    %{vector: Enum.map(vector, &(&1 * 1.0)), label: label}
  end

  defp normalize_reference!(_reference) do
    raise ArgumentError, "reference vector must contain #{@vector_dimensions} dimensions"
  end

  defp read_json!(path) do
    body =
      case Path.extname(path) do
        ".gz" ->
          path
          |> File.read!()
          |> :zlib.gunzip()

        _ ->
          File.read!(path)
      end

    Jason.decode!(body)
  end

  defp squared_distance(left, right) do
    left
    |> Enum.zip(right)
    |> Enum.reduce(0.0, fn {left_value, right_value}, acc ->
      delta = left_value - right_value
      acc + delta * delta
    end)
  end

  defp clamp(value) when is_integer(value), do: clamp(value * 1.0)
  defp clamp(value), do: value |> max(0.0) |> min(1.0)

  defp bool_as_unit(true), do: 1.0
  defp bool_as_unit(false), do: 0.0
end
