defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_info = %{
      email: auth.info.email,
      name: auth.info.name,
      image: auth.info.image
    }

    json(conn, user_info)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "OAuth failed"})
  end
end
