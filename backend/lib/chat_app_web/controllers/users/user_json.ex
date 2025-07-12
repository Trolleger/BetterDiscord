defmodule ChatAppWeb.Users.UserJSON do
  alias ChatApp.Auth.User

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

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      username: user.username
    }
  end
end
