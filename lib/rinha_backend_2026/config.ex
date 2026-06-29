defmodule RinhaBackend2026.Config do
  @moduledoc false

  def port do
    System.get_env("PORT", "9999")
    |> String.to_integer()
  end

  def resource_paths do
    %{
      normalization: System.get_env("RINHA_NORMALIZATION_PATH", "resources/normalization.json"),
      mcc_risk: System.get_env("RINHA_MCC_RISK_PATH", "resources/mcc_risk.json"),
      references: System.get_env("RINHA_REFERENCES_PATH", "resources/example-references.json")
    }
  end
end
