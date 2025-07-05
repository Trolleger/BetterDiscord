defmodule ChatAppWeb.Auth.SessionController do
  use ChatAppWeb, :controller
  alias ChatApp.Guardian
  alias ChatApp.Accounts
  alias ChatApp.Auth.RefreshToken

  # POST /api/register
  # Expects JSON %{ "user" => %{ email, username, password } }
  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{id: user.id, email: user.email, username: user.username})
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  # POST /api/login
  # Expects JSON %{ "user" => %{ login, password } }
  def login(conn, %{"user" => %{"login" => login, "password" => password}}) do
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

  # POST /api/refresh
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

  # DELETE /api/logout
  def logout(conn, _params) do
    conn = fetch_cookies(conn)
    if token = conn.cookies["refresh_token"], do: Accounts.revoke_refresh_token(token)

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

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, val}, acc ->
      String.replace(acc, "%{#{key}}", to_string(val))
    end)
  end
end
