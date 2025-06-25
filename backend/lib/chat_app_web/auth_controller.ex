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
  # Extract the full name from OAuth data, fallback to empty string if missing
  full_name = auth.info.name || ""

  # Split full name into first name and the rest as last name
  [first_name | rest] = String.split(full_name)
  last_name = Enum.join(rest, " ") || "Unknown"  # Use "Unknown" if last name missing

  # Build a map of user attributes for lookup or creation in DB
  user_attrs = %{
    first_name: first_name,
    last_name: last_name,
    email: auth.info.email,
    provider: to_string(auth.provider),  # Convert provider atom to string, e.g., "google"
    provider_uid: auth.uid               # Unique ID from the OAuth provider
  }

  # Try to find or create the user in your system
  with {:ok, user} <- ChatApp.Accounts.get_or_create_oauth_user(user_attrs) do
    # Check if the user has a username set
    if is_nil(user.username) do
      # User has no username yet — needs to complete profile

      # Create a temporary JWT token (with type :temp) to hold user state securely
      {:ok, temp_token, _claims} = ChatApp.Guardian.encode_and_sign(user, %{}, token_type: :temp)

      conn
      # Store the temp token in an HTTP-only cookie, expires in 5 minutes (300 seconds)
      |> put_resp_cookie("temp_user_token", temp_token, http_only: true, max_age: 300)
      # Redirect the user to frontend route "/complete-profile" to finish setup
      |> redirect(to: "/complete-profile")
    else
      # User has username — issue a full JWT token for normal login
      {:ok, token, _claims} = ChatApp.Guardian.encode_and_sign(user)

      # Return the token and basic user info as JSON (for SPA frontend to consume)
      json(conn, %{token: token, user: %{id: user.id, email: user.email, username: user.username}})
    end
  else
    # Something failed in user creation or retrieval — respond with unauthorized error
    _error ->
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
