defmodule AuthTutorialPhoenixWeb.UserView do
  use AuthTutorialPhoenixWeb, :view

  alias AuthTutorialPhoenixWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      inserted_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
