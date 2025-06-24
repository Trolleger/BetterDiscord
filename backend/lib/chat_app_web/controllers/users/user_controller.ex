defmodule ChatAppWeb.Users.UserController do
  use ChatAppWeb, :controller
  alias ChatApp.Accounts

  # Handles fallback for errors like validation failures
  action_fallback ChatAppWeb.FallbackController

  # POST /api/users
  # Register new user
  def register(conn, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "User successfully registered",
          email: user.email,
          username: user.username
        })

      {:error, changeset} ->
        {:error, changeset}
    end

  end
end
