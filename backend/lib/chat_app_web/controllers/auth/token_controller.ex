defmodule ChatAppWeb.Auth.TokenController do
  use ChatAppWeb, :controller
  # This controller handles auth token actions under /api/socket-token

  @doc """
  GET /api/socket-token
  Returns a Phoenix.Token signed for socket authentication if user is authenticated.
  If no authenticated user found, responds with 401 Unauthorized.
  """
  def socket(conn, _params) do
    # Fetch the currently authenticated user from Guardian pipeline
    user = Guardian.Plug.current_resource(conn)

    case user do
      nil ->
        # No authenticated user, deny access
        conn |> send_resp(401, "unauthorized")

      user ->
        # Sign a Phoenix.Token scoped for user socket with user ID
        token = Phoenix.Token.sign(conn, "user socket", user.id)

        # Respond with the token as JSON
        json(conn, %{token: token})
    end
  end
end
