defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  alias ChatApp.Guardian
  plug ChatApp.Guardian.AuthPipeline

  @doc "GET /api/profile"
  def profile(conn, _), do: json(conn, %{user: Guardian.Plug.current_resource(conn)})

  @doc "OAuth request handler - placeholder for future OAuth implementation"
  def request(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> json(%{error: "OAuth not implemented yet"})
  end

  @doc "OAuth callback handler - placeholder for future OAuth implementation"
  def callback(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> json(%{error: "OAuth not implemented yet"})
  end

  @doc "Complete profile handler - placeholder for future implementation"
  def complete_profile(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> json(%{error: "Complete profile not implemented yet"})
  end
end
