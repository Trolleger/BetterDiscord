defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug Ueberauth

  # This handles the initial OAuth request phase
  def request(conn, %{"provider" => provider}) do
    # This function is called but Ueberauth's plug handles the redirect
    # Just return the conn to let Ueberauth process it
    conn
  end

  # This is called after the provider redirects back with auth info
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_info = %{
      name: auth.info.name,
      email: auth.info.email,
      image: auth.info.image,
      provider: to_string(auth.provider)
    }

    # Your logic here: create or find user, set session, etc.
    json(conn, %{status: "success", user: user_info})
  end

  # Handle auth failures
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    json(conn, %{status: "error", message: "Authentication failed"})
  end
end
