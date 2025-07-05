defmodule ChatAppWeb.Auth.SessionController do
  use ChatAppWeb, :controller

  alias ChatApp.Guardian
  alias ChatApp.Accounts
  alias Plug.Conn

  @doc """
  POST /api/login
  Expects JSON %{ "login" => login, "password" => pwd }.
  On success sets access token, refresh token cookie, stores refresh token in DB.
  """
  def login(conn, %{"login" => login, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user_by_login(login, password),
         {:ok, access_token, _} <- Guardian.encode_and_sign(user, %{typ: "access"}),
         {:ok, refresh_token, _} <- Guardian.encode_and_sign(user, %{typ: "refresh"}, token_ttl: {30, :days}),
         {:ok, _} <- Accounts.create_refresh_token(user, refresh_token) do
      conn
      |> put_resp_cookie("refresh_token", refresh_token,
        http_only: true,
        secure: secure_cookie?(conn),
        same_site: "Lax",
        max_age: 2_592_000)
      |> json(%{access_token: access_token, user: %{id: user.id, email: user.email, username: user.username}})
    else
      {:error, :user_not_found} -> unauthorized(conn)
      {:error, :invalid_password} -> unauthorized(conn)
      _ -> internal_error(conn)
    end
  end

  @doc """
  POST /api/refresh
  Uses refresh token from cookie or JSON params.
  Issues new tokens, revokes old refresh token, stores new one.
  """
  def refresh(conn, params) do
    conn = fetch_cookies(conn)

    token = conn.cookies["refresh_token"] || Map.get(params, "refresh_token")

    if is_nil(token) do
      unauthorized(conn)
    else
      with %RefreshToken{user: user} <- Accounts.get_valid_refresh_token(token),
           {:ok, new_access, _} <- Guardian.encode_and_sign(user, %{typ: "access"}),
           {:ok, new_refresh, _} <- Guardian.encode_and_sign(user, %{typ: "refresh"}, token_ttl: {30, :days}),
           {:ok, _} <- Accounts.revoke_refresh_token(token),
           {:ok, _} <- Accounts.create_refresh_token(user, new_refresh) do
        conn
        |> put_resp_cookie("refresh_token", new_refresh,
          http_only: true,
          secure: secure_cookie?(conn),
          same_site: "Lax",
          max_age: 2_592_000)
        |> json(%{access_token: new_access})
      else
        _ -> unauthorized(conn)
      end
    end
  end

  @doc """
  DELETE /api/logout
  Revokes refresh token server-side and clears cookie client-side.
  """
  def logout(conn, _params) do
    conn = fetch_cookies(conn)
    token = conn.cookies["refresh_token"]

    if token, do: Accounts.revoke_refresh_token(token)

    conn
    |> delete_resp_cookie("refresh_token")
    |> json(%{ok: true})
  end

  defp secure_cookie?(conn) do
    endpoint = conn.private[:phoenix_endpoint] || ChatAppWeb.Endpoint
    endpoint.config(:force_ssl) || endpoint.config(:url)[:scheme] == "https"
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Unauthorized"})
  end

  defp internal_error(conn) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "Internal server error"})
  end
end
