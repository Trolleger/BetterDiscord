defmodule ChatAppWeb.Auth.TokenController do
  use ChatAppWeb, :controller
# Defines the module. It lives under your /auth/ path, grouped with all your other auth stuff.
  def socket(conn, _params) do
      # Turns this file into a controller and gives it access to controller functions
    case conn.assigns[:current_user] do
      # The action, it is mapped to something like GET /api/socket-token. (May be something different infuture)
      nil ->
        # If no user, deny access
        conn |> send_resp(401, "unauthorized")
      user ->
        token = Phoenix.Token.sign(conn, "user socket", user.id)
        json(conn, %{token: token})
        # Otherwise we sign a new token scoped to "user socket" with the user's ID. That’s what we’ll send to the socket.
    end
  end
end
