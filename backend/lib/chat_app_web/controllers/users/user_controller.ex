defmodule ChatAppWeb.Users.UserController do
  use ChatAppWeb, :controller
  alias ChatApp.Accounts

  # Use fallback controller to handle errors not caught here
  action_fallback ChatAppWeb.FallbackController

  # This action handles user registration
  # Expects params directly as %{ "email" => ..., "username" => ..., "password" => ... }
  def register(conn, user_params) do
    # Try to create user with given params
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created) # HTTP 201 Created
        |> json(%{
          message: "User successfully registered",
          email: user.email,
          username: user.username
        })
      {:error, changeset} ->
        # Return the error tuple - fallback controller will handle it
        {:error, changeset}
    end
  end
end
