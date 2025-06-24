defmodule ChatAppWeb.UserView do
  use ChatAppWeb, :json

  def render("index.json", %{users: users}) do
    %{data: Enum.map(users, &user_json/1)}
  end

  def render("show.json", %{user: user}) do
    %{data: user_json(user)}
  end

  defp user_json(user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      username: user.username,  # Added username field
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
