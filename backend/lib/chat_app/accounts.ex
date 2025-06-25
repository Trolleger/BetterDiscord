defmodule ChatApp.Accounts do
  @moduledoc """
  Handles user registration, authentication, OAuth linking, and username updates.
  """

  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias ChatApp.Accounts.User
  alias Bcrypt

  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, plain_password) do
    case get_by_email(email) do
      nil -> {:error, :user_not_found}
      %User{hashed_password: hashed_password} = user ->
        if hashed_password && Bcrypt.verify_pass(plain_password, hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
    end
  end

  def get_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_by_id!(id), do: Repo.get!(User, id)

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

      user -> {:ok, user}
    end
  end

  def update_username(user, attrs) do
    user
    |> User.username_changeset(attrs)
    |> Repo.update()
  end
end
