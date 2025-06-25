defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug Ueberauth
  alias ChatApp.Accounts
  alias ChatApp.Guardian

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_attrs = %{
      email: auth.info.email,
      username: auth.info.nickname || "",
      provider: to_string(auth.provider),
      provider_uid: auth.uid
    }

    case Accounts.get_or_create_oauth_user(user_attrs) do
      {:ok, user} ->
        if is_nil(user.username) or user.username == "" do
          {:ok, temp_token, _} = Guardian.encode_and_sign(user, %{}, token_type: :temp)
          conn
          |> put_resp_cookie("temp_user_token", temp_token, http_only: true, secure: true, max_age: 300)
          |> redirect(to: "/complete-profile")
        else
          {:ok, token, _} = Guardian.encode_and_sign(user)
          json(conn, %{token: token, user: %{id: user.id, email: user.email, username: user.username}})
        end
      _ ->
        conn |> put_status(:unauthorized) |> json(%{error: "OAuth login failed"})
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    # TODO: Make this configurable via environment variables
    redirect_url = Application.get_env(:chat_app, :frontend_url, "http://localhost:3000") <> "/?auth=error"
    conn |> redirect(external: redirect_url)
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> delete_resp_cookie("ruid")
    |> delete_resp_cookie("temp_user_token")
    |> json(%{message: "Logged out successfully"})
  end

  def user(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
      nil -> conn |> put_status(:unauthorized) |> json(%{error: "Not authenticated"})
      user -> json(conn, %{id: user.id, email: user.email, username: user.username, provider: user.provider})
    end
  end

  def complete_profile(conn, %{"username" => username}) do
    temp_token = conn |> Plug.Conn.fetch_cookies() |> Map.get(:cookies) |> Map.get("temp_user_token")

    with {:ok, claims} <- Guardian.decode_and_verify(temp_token, token_type: :temp),
         user = Accounts.get_by_id!(claims["sub"]),
         {:ok, _} <- Accounts.update_username(user, %{"username" => username}) do
      {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute})
      {:ok, refresh_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

      conn
      |> delete_resp_cookie("temp_user_token")
      |> put_resp_cookie("ruid", refresh_token, http_only: true, secure: true, max_age: 7 * 24 * 3600)
      |> json(%{access_token: access_token, user: %{id: user.id, email: user.email, username: user.username}})
    else
      _ -> conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired token"})
    end
  end
end
