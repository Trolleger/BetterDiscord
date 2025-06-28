defmodule ChatApp.Accounts do
  @moduledoc """
  Handles user registration, authentication, OAuth linking, and username updates.
  """
  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias ChatApp.Auth.User
  alias Bcrypt

  # Creates a new user with registration params
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # Authenticates user by email and password
  def authenticate_user(email, plain_password) do
    case get_by_email(email) do
      nil ->
        {:error, :user_not_found}

      %User{hashed_password: hashed_password} = user ->
        if hashed_password && Bcrypt.verify_pass(plain_password, hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
    end
  end

  # Authenticates user by email OR username
  def authenticate_user_by_login(email_or_username, password) do
    user =
      case is_valid_email?(email_or_username) do
        true -> Repo.get_by(User, email: email_or_username)
        false -> Repo.get_by(User, username: email_or_username)
      end

    case user do
      nil ->
        {:error, :user_not_found}

      %User{hashed_password: nil} ->
        {:error, :invalid_password}

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

  # Get user by email
  def get_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  # Get user by ID, raise if not found
  def get_by_id!(id) do
    Repo.get!(User, id)
  end

  # Find or create user via OAuth data
  def get_or_create_oauth_user(%{
        email: email,
        provider: provider,
        provider_uid: provider_uid,
        username: username
      }) do
    case Repo.get_by(User, provider: provider, provider_uid: provider_uid) do
      nil ->
        case Repo.get_by(User, email: email) do
          nil ->
            %User{}
            |> User.oauth_changeset(%{
              email: email,
              provider: provider,
              provider_uid: provider_uid,
              username: username
            })
            |> Repo.insert()

          user ->
            user
            |> User.oauth_changeset(%{
              provider: provider,
              provider_uid: provider_uid
            })
            |> Repo.update()
        end

      user ->
        {:ok, user}
    end
  end

  # Update username for a user
  def update_username(%User{} = user, attrs) do
    user
    |> User.username_changeset(attrs)
    |> Repo.update()
  end
end
