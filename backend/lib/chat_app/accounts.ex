defmodule ChatApp.Accounts do
  @moduledoc """
  The Accounts context.

  Provides user creation, lookup, and authentication functions.
  Also handles OAuth user retrieval/creation.
  """

  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias ChatApp.Accounts.User

  @doc """
  Creates a new user via `registration_changeset/2`,
  which hashes the password into `:hashed_password`.
  """
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetches a user by email.
  Returns `{:ok, user}` or `{:error, :not_found}`.
  """
  def get_by_email(email) do
    query = from(u in User, where: u.email == ^email)

    case Repo.one(query) do
      nil ->
        IO.inspect(email, label: "[AUTH] Email not found in DB")
        {:error, :not_found}

      user ->
        {:ok, user}
    end
  end

  @doc """
  Fetches a user by ID or raises if not found.
  Used by Guardian for token lookup.
  """
  def get_by_id!(id), do: Repo.get!(User, id)

  @doc """
  Authenticates a user given email and plain-text password.

  Returns:
    - `{:ok, user}` if credentials match,
    - `{:error, :unauthorized}` if password is wrong,
    - `{:error, :not_found}` if the email does not exist.
  """
  def authenticate_user(email, password) do
    with {:ok, user} <- get_by_email(email) do
      if validate_password(password, user.hashed_password) do
        {:ok, user}
      else
        {:error, :unauthorized}
      end
    end
  end

  @doc false
  # Uses Bcrypt to compare raw password with stored hash
  defp validate_password(password, hashed_password) do
    Bcrypt.verify_pass(password, hashed_password)
  end

  @doc """
  Finds or creates a user from OAuth data.
  - Checks by provider+provider_uid first.
  - Falls back to email match for linking accounts.
  - If found by email but missing provider info, updates it.
  - Creates new user with `oauth_changeset/2` if none found.
  """
  def get_or_create_oauth_user(%{
        email: email,
        provider: provider,
        provider_uid: provider_uid
      } = attrs) do
    case Repo.get_by(User, provider: provider, provider_uid: provider_uid) do
      nil ->
        case Repo.get_by(User, email: email) do
          nil ->
            %User{}
            |> User.oauth_changeset(attrs)
            |> Repo.insert()

          user ->
            changeset =
              user
              |> User.oauth_changeset(attrs)

            case Repo.update(changeset) do
              {:ok, updated_user} -> {:ok, updated_user}
              {:error, changeset} -> {:error, changeset}
            end
        end

      user ->
        {:ok, user}
    end
  end
end
