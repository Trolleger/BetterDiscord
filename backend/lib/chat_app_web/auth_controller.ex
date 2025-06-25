defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller
  plug(Ueberauth)

  # OAuth request phase: handled by Ueberauth redirecting to provider
  def request(conn, %{"provider" => _provider}) do
    conn
  end

  # OAuth callback: provider redirects here with user info
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # Extract full name, split into first + last
    full_name = auth.info.name || ""
    [first_name | rest] = String.split(full_name)
    last_name = Enum.join(rest, " ") || "Unknown"

    # Prepare attrs for user find/create
    user_attrs = %{
      first_name: first_name,
      last_name: last_name,
      email: auth.info.email,
      provider: to_string(auth.provider),
      provider_uid: auth.uid
    }

    with {:ok, user} <- ChatApp.Accounts.get_or_create_oauth_user(user_attrs) do
      if is_nil(user.username) do
        # No username means incomplete profile — create temp JWT token
        {:ok, temp_token, _claims} = ChatApp.Guardian.encode_and_sign(user, %{}, token_type: :temp)

        conn
        |> put_resp_cookie("temp_user_token", temp_token, http_only: true, max_age: 300)
        |> redirect(to: "/complete-profile")
      else
        # Complete user — issue full JWT token for SPA
        {:ok, token, _claims} = ChatApp.Guardian.encode_and_sign(user)

        json(conn, %{
          token: token,
          user: %{id: user.id, email: user.email, username: user.username}
        })
      end
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "OAuth login failed"})
    end
  end

  # OAuth failure handler (e.g., user denied permissions)
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> redirect(external: "http://localhost:3000/?auth=error&message=Authentication failed")
  end

  # Logout clears session and confirms
  def logout(conn, _params) do
    conn
    |> clear_session()
    |> json(%{message: "Logged out successfully"})
  end

  # Returns current user info from session or 401 if none
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

  # --- Profile completion endpoint ---

  def complete_profile(conn, %{"username" => username}) do
    with {:ok, temp_token} <- fetch_temp_token(conn),
         {:ok, user, _claims} <- ChatApp.Guardian.resource_from_token(temp_token),
         :ok <- validate_username(username),
         {:ok, updated_user} <- update_username(user, username),
         {:ok, full_token, _claims} <- ChatApp.Guardian.encode_and_sign(updated_user) do
      # Clear temp token cookie since profile is now complete
      conn
      |> delete_resp_cookie("temp_user_token")
      |> json(%{
        token: full_token,
        user: %{id: updated_user.id, email: updated_user.email, username: updated_user.username}
      })
    else
      {:error, :missing_token} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Missing or invalid token"})

      {:error, :invalid_token} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid token"})

      {:error, :invalid_username} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Username invalid or taken"})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Something went wrong"})
    end
  end

  # Helpers for complete_profile action

  defp fetch_temp_token(conn) do
    case Plug.Conn.get_req_cookie(conn, "temp_user_token") do
      nil -> {:error, :missing_token}
      token -> {:ok, token}
    end
  end

  defp validate_username(username) do
    # Basic check: alphanumeric + underscores, length 3-20, unique in DB
    if Regex.match?(~r/^\w{3,20}$/, username) and !username_taken?(username) do
      :ok
    else
      {:error, :invalid_username}
    end
  end

  defp username_taken?(username) do
    ChatApp.Repo.get_by(ChatApp.Accounts.User, username: username) != nil
  end

  defp update_username(user, username) do
    user
    |> ChatApp.Accounts.User.username_changeset(%{username: username})
    |> ChatApp.Repo.update()
  end
end
