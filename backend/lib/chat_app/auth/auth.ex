defmodule ChatApp.Auth do
  @moduledoc """
  Auth context: user registration, authentication, token logic.
  Fully manual now; schema has placeholders for future OAuth.
  """
  alias ChatApp.Repo
  alias ChatApp.Auth.User
  alias Bcrypt

  # register a new user
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # authenticate with email OR username
  def authenticate_user(email_or_username, password) do
    user = case is_valid_email?(email_or_username) do
      true -> Repo.get_by(User, email: email_or_username)
      false -> Repo.get_by(User, username: email_or_username)
    end

    case user do
      nil ->
        {:error, :not_found}
      %User{hashed_password: hash} = user ->
        if Bcrypt.verify_pass(password, hash) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
    end
  end

  # Better email validation than just checking for "@"
  defp is_valid_email?(string) do
    email_regex = ~r/^[^\s]+@[^\s]+\.[^\s]+$/
    String.match?(string, email_regex)
  end

  # fetch user by id
  def get_user!(id), do: Repo.get!(User, id)
end
