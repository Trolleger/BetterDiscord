defmodule ChatAppWeb.Auth.SessionController do
  use ChatAppWeb, :controller
  alias ChatApp.Accounts
  alias ChatApp.Guardian
  action_fallback ChatAppWeb.FallbackController

  @doc "POST /api/register"
  def register(conn, %{"user" => params}) do
    with {:ok, _user} <- Accounts.create_user(params) do
      send_resp(conn, :created, ~s({"message":"registered"}))
    end
  end

  @doc "POST /api/login"
  def login(conn, %{"user" => %{"login" => login, "password" => password}}) do
    with {:ok, user} <- Accounts.authenticate_user_by_login(login, password),
         {:ok, access, _} <- Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute}),
         {:ok, refresh, _} <- Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day}) do
      conn
      |> put_resp_cookie("ruid", refresh, http_only: true, secure: Mix.env() == :prod, same_site: "Lax", max_age: 7 * 24 * 3600)
      |> json(%{access_token: access})
    end
  end

  @doc "POST /api/refresh"
  def refresh(conn, _params) do
    conn = fetch_cookies(conn)
    case Guardian.exchange(conn.cookies["ruid"], "refresh", "access", ttl: {15, :minute}) do
      {:ok, _old, {new_access, _}} -> json(conn, %{access_token: new_access})
      _ -> conn |> put_status(:unauthorized) |> json(%{error: "unauthorized"})
    end
  end

  @doc "DELETE /api/logout"
  def logout(conn, _params), do: conn |> delete_resp_cookie("ruid") |> send_resp(:ok, "logged out")
end
