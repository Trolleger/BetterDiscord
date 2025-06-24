defmodule ChatAppWeb.Users.UserJSON do
  alias ChatApp.Accounts.User

  @doc """
  Renders a list of users.
  This is used for actions that return multiple users (like index).
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  This is used for actions that return one user (like show).
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  # This is the actual map of user data we expose to the frontend.
  # It MUST only include fields that are defined in the User schema.
  # NEVER include sensitive fields like password or hashed_password.
  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      username: user.username
      # Removed: first_name and last_name (they don't exist in schema)
      # Removed: password (should NEVER be sent to frontend)
    }
  end
end
