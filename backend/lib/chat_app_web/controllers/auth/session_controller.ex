defmodule ChatAppWeb.Auth.SessionController do
  use ChatAppWeb, :controller

  alias ChatApp.Accounts
  alias ChatApp.Guardian

  # Handles fallback responses for errors like validation, not found, etc.
  action_fallback ChatAppWeb.FallbackController

  @doc """
  Manual user registration.
  Expects:
    %{"user" => %{"email" => ..., "username" => ..., "password" => ...}}

  Returns 201 (created) on success, or 422 (unprocessable entity) with validation errors.
  """
  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_status(:created)
        |> json(%{message: "User registered successfully"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset_errors(changeset)})
    end
  end

  @doc """
  Manual login endpoint.
  Expects:
    %{"user" => %{"email" => ..., "password" => ...}}

  Returns:
    - JSON with access_token
    - HTTP-only refresh token (stored as cookie "ruid")
  """
  def new(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        # Generate access and refresh tokens
        {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute})
        {:ok, refresh_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

        # Decide whether to secure the cookie based on the environment (only secure in prod)
        secure_cookie? = Mix.env() == :prod

        # Set the refresh token in the response as an HTTP-only cookie
        conn
        |> put_resp_cookie("ruid", refresh_token,
          http_only: true,
          secure: secure_cookie?,
          max_age: 7 * 24 * 60 * 60,  # 7 days in seconds
          same_site: "Lax"           # Prevent CSRF issues
        )
        |> put_status(:created)     # Return 201 Created
        |> json(%{access_token: access_token})  # Send access token in the response

      {:error, _} ->
        conn
        |> put_status(:unauthorized)  # Return 401 Unauthorized if login fails
        |> json(%{error: "unauthorized"})
    end
  end

  # Fallback for missing login parameters (e.g. email/password not provided)
  def new(conn, _params) do
    conn
    |> put_status(:bad_request)  # Return 400 Bad Request if parameters are missing
    |> json(%{error: "Missing user parameters"})
  end

  @doc """
  Refresh access token using the `ruid` refresh token stored in cookies.

  If the refresh token is valid, return a new access token.
  """
  def refresh(conn, _params) do
    conn = Plug.Conn.fetch_cookies(conn)  # Fetch cookies from the request
    refresh_token = Map.get(conn.cookies, "ruid")  # Extract the refresh token

    # Exchange the old refresh token for a new access token
    with {:ok, _old_token, {access_token, _}} <-
           Guardian.exchange(refresh_token, "refresh", "access", ttl: {15, :minute}) do
      conn
      |> put_status(:created)  # Return 201 Created with the new access token
      |> json(%{access_token: access_token})
    else
      _ ->
        conn
        |> put_status(:unauthorized)  # Return 401 Unauthorized if refresh fails
        |> json(%{error: "unauthorized"})
    end
  end

  @doc """
  Logout endpoint.

  Deletes the `ruid` refresh token cookie to invalidate the session.
  """
  def delete(conn, _params) do
    conn
    |> delete_resp_cookie("ruid")  # Delete the refresh token cookie
    |> put_status(:ok)             # Return 200 OK
    |> text("Logged out successfully")
  end

  # Helper function to convert changeset errors into a readable map format
  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))  # Replace placeholders with actual values
      end)
    end)
  end
end
