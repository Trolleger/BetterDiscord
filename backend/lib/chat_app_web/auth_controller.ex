defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug Ueberauth

  def request(conn, %{"provider" => _provider}) do
    # Ueberauth handles the redirect automatically
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_info = %{
      name: auth.info.name,
      email: auth.info.email,
      image: auth.info.image,
      provider: to_string(auth.provider)
    }

    # Redirect back to frontend with success
    conn
    |> put_session(:current_user, user_info)
    |> redirect(external: "http://localhost:3001/?auth=success&user=#{URI.encode(Jason.encode!(user_info))}")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> redirect(external: "http://localhost:3001/?auth=error&message=Authentication failed")
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> json(%{message: "Logged out successfully"})
  end

  def user(conn, _params) do
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not authenticated"})
      user ->
        json(conn, %{user: user})
    end
  end
end
