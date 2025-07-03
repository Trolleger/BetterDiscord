defmodule ChatAppWeb.Auth.SessionController do
  use ChatAppWeb, :controller
  alias ChatApp.Accounts
  alias ChatApp.Guardian

  action_fallback(ChatAppWeb.FallbackController)

  @doc "POST /api/register"
  def register(conn, %{"user" => params}) do
    with {:ok, _user} <- Accounts.create_user(params) do
      send_resp(conn, :created, ~s({"message":"registered"}))
    end
  end

  @doc "POST /api/login"
  def login(conn, %{"user" => %{"login" => login, "password" => password}}) do
    :timer.sleep(100)

    with {:ok, user} <- Accounts.authenticate_user_by_login(login, password),
         {:ok, access, _} <-
           Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute}),
         {:ok, refresh, _} <-
           Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {1, :day}) do
      conn
      |> put_resp_cookie("ruid", refresh,
        http_only: true,
        secure: Mix.env() == :prod,
        same_site: "Lax",
        max_age: 24 * 3600
      )
      |> json(%{access_token: access})
    else
      _ ->
        :timer.sleep(100)

        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  @doc "POST /api/refresh"
  def refresh(conn, _params) do
    conn = fetch_cookies(conn)

    with refresh_token when is_binary(refresh_token) <- conn.cookies["ruid"],
         {:ok, user, claims} <- Guardian.resource_from_token(refresh_token),
         "refresh" <- claims["typ"],
         {:ok, access, _} <-
           Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute}),
         {:ok, new_refresh, _} <-
           Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {1, :day}) do
      conn
      |> put_resp_cookie("ruid", new_refresh,
        http_only: true,
        secure: Mix.env() == :prod,
        same_site: "Lax",
        max_age: 24 * 3600
      )
      |> json(%{access_token: access})
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unauthorized"})
    end
  end

  @doc "DELETE /api/logout"
  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("ruid")
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, ~s({"message":"logged out"}))
  end
end
