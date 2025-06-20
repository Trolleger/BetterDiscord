# lib/chat_app_web/controllers/auth_controller.ex
defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug Ueberauth

  # OAuth request phase: Ueberauth handles redirect to provider automatically
  def request(conn, %{"provider" => _provider}) do
    # Ueberauth will redirect to the provider's login page automatically
    conn
  end

  # OAuth callback phase: provider redirects back here with user info
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # Extract full name from provider info or fallback to empty string
    full_name = auth.info.name || ""
    [first_name | rest] = String.split(full_name)
    last_name = Enum.join(rest, " ") || "Unknown"  # fallback if last name missing

    # Build attrs for finding or creating user with OAuth info
    user_attrs = %{
      first_name: first_name,
      last_name: last_name,
      email: auth.info.email,
      provider: to_string(auth.provider),  # convert atom to string like "google"
      provider_uid: auth.uid                # unique ID from provider
    }

    # Try to find or create user, then sign a JWT token with Guardian
    with {:ok, user} <- ChatApp.Accounts.get_or_create_oauth_user(user_attrs),
         {:ok, token, _claims} <- ChatApp.Guardian.encode_and_sign(user) do
      # Return JSON with JWT token and basic user info for frontend
      json(conn, %{token: token, user: %{id: user.id, email: user.email}})
    else
      _error ->
        # Something went wrong with OAuth or token generation
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "OAuth login failed"})
    end
  end

  # Handle OAuth failures (e.g., user denied permissions)
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> redirect(external: "http://localhost:3000/?auth=error&message=Authentication failed")
  end

  # Logout endpoint: clears session and confirms logout
  def logout(conn, _params) do
    conn
    |> clear_session()
    |> json(%{message: "Logged out successfully"})
  end

  # User info endpoint: returns current user from session or 401 if none
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
