defmodule ChatAppWeb.Auth.SessionController do
  use ChatAppWeb, :controller
  alias ChatApp.Guardian
  alias ChatApp.Accounts
  alias Plug.Conn

  @doc """
  POST /api/login
  Expects JSON %{ "login" => email_or_username, "password" => pwd }.
  On success: sets http_only, SameSite=Lax cookie with refresh token and
  returns JSON %{ access_token: "...", user: %{ ... } }.
  """
  def login(conn, %{"login" => login, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user_by_login(login, password),
         {:ok, access_token, _access_claims} <- Guardian.encode_and_sign(user, %{typ: "access"}),
         {:ok, refresh_token, _refresh_claims} <- Guardian.encode_and_sign(user, %{typ: "refresh"}, token_ttl: {30, :days}) do

      conn
      |> put_resp_cookie("refresh_token", refresh_token, http_only: true, secure: secure_cookie?(conn), same_site: "Lax", max_age: 2_592_000)
      |> json(%{access_token: access_token, user: %{id: user.id, email: user.email, username: user.username}})
    else
      {:error, :user_not_found} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
      {:error, :invalid_password} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
    end
  end

  @doc """
  POST /api/refresh
  For web/Electron: reads refresh_token cookie.
  For mobile: expects JSON %{ "refresh_token" => token }.
  Returns new access + refresh tokens, resets cookie if applicable.
  """
  def refresh(conn, params) do
    token =
      case Conn.get_req_cookie(conn, "refresh_token") do
        nil -> Map.get(params, "refresh_token")
        cookie -> cookie
      end

    with {:ok, _old_claims} <- Guardian.decode_and_verify(token, %{"typ" => "refresh"}),
         {:ok, user} <- Guardian.resource_from_token(token),
         {:ok, new_access, _} <- Guardian.encode_and_sign(user, %{typ: "access"}),
         {:ok, new_refresh, _} <- Guardian.encode_and_sign(user, %{typ: "refresh"}, token_ttl: {30, :days}) do

      conn2 =
        conn
        |> put_resp_cookie("refresh_token", new_refresh, http_only: true, secure: secure_cookie?(conn), same_site: "Lax", max_age: 2_592_000)
      conn2
      |> json(%{access_token: new_access})
    else
      _ ->
        conn |> put_status(:unauthorized) |> json(%{error: "Could not refresh token"})
    end
  end

  @doc """
  DELETE /api/logout
  Clears the refresh_token cookie so the browser can no longer refresh.
  """
  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("refresh_token")
    |> json(%{ok: true})
  end

  defp secure_cookie?(conn) do
    endpoint = conn.private[:phoenix_endpoint] || ChatAppWeb.Endpoint
    endpoint.config(:force_ssl) || endpoint.config(:url)[:scheme] == "https"
  end
end
