# lib/chat_app/accounts.ex
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
      nil  ->
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
      # Debug output for authentication check
      # IO.inspect(email, label: "[AUTH] Email")
      # IO.inspect(password, label: "[AUTH] Raw password input")
      # IO.inspect(user.hashed_password, label: "[AUTH] Stored password hash in DB")

      if validate_password(password, user.hashed_password) do
        # IO.puts("[AUTH] Password valid ✔")
        {:ok, user}
      else
        # IO.puts("[AUTH] Password mismatch ❌")
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
  - Creates new user with `oauth_changeset/2` if none found.
  """
  def get_or_create_oauth_user(%{email: email, provider: provider, provider_uid: provider_uid} = attrs) do
    user =
      Repo.get_by(User, provider: provider, provider_uid: provider_uid) ||
      Repo.get_by(User, email: email)

    case user do
      nil ->
        %User{}
        |> User.oauth_changeset(attrs)
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end
end
