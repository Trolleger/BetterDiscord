defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug Ueberauth

  def request(conn, %{"provider" => provider}) do
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
    |> redirect(external: "http://localhost/?auth=success&user=#{URI.encode(Jason.encode!(user_info))}")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> redirect(external: "http://localhost/?auth=error&message=Authentication failed")
  end
end
