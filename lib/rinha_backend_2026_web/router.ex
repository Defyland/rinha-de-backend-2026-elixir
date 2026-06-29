defmodule RinhaBackend2026Web.Router do
  @moduledoc false

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/ready" do
    json(conn, 200, RinhaBackend2026.ready_status())
  end

  post "/fraud-score" do
    case RinhaBackend2026.score(conn.body_params) do
      {:ok, payload} ->
        json(conn, 200, payload)

      {:error, reason} ->
        json(conn, 422, %{error: reason})
    end
  end

  match _ do
    json(conn, 404, %{error: "not_found"})
  end

  defp json(conn, status, payload) do
    body = Jason.encode!(payload)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, body)
  end
end
