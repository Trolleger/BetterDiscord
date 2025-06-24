defmodule ChatAppWeb.Users.ProfileController do
  use ChatAppWeb, :controller
  # Loads controller stuff so we can use it in our code

  def show(conn, _params) do
    # Creates a show function. conn is the connection struct that holds all request and response info.
    # _params is the request parameters but we aren't using it here, so we put _params to tell Elixir we acknowledge it but won't use it.
    # The function processes the request and sends back a response.

    case Guardian.Plug.current_resource(conn) do
      # This function comes from Guardian and looks into the resources Guardian collected DURING the request (specifically from the LoadResource plug).
      # The plug verifies the token, and current_resource(conn) asks: "Who is the current resource (user) loaded?"
      # It’s like accessing conn.assigns[:guardian_default_resource], but that’s hardcoded.
      # Using current_resource(conn) is easier to refactor and safer if the key or config changes.
      # If you don't know what conn.assigns is — conn is a struct holding all info about the HTTP request and response going through Phoenix.
      # Think of it like a backpack carrying everything related to this connection.
      # assigns is like a map where you can stash stuff during the request.
      # Data in conn.assigns is temporary and only exists for the current request!

      nil ->
        # No user found case
        conn
        |> put_status(:unauthorized)
        # Sets HTTP status 401.
        |> json(%{error: "Unauthorized"})
        # Returns JSON error.

      user ->
        # User found case
        conn
        |> put_status(:ok)
        # Sets HTTP status 200.
        |> json(%{
          id: user.id,
          email: user.email,
          username: user.username
          # Sends back user info as JSON.
        })
    end
  end
end
