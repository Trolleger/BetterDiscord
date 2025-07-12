defmodule ChatApp.Accounts do
  @moduledoc """
  Handles user registration, authentication, OAuth linking, username updates,
  and refresh token management.
  """

  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias ChatApp.Auth.{User, RefreshToken}
  alias Bcrypt

  @refresh_token_ttl_days 30

  # Create user with registration changeset
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # Authenticate by email and password
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

  # Authenticate by login (email or username) and password
  def authenticate_user_by_login(email_or_username, password) do
    user =
      if is_valid_email?(email_or_username) do
        Repo.get_by(User, email: email_or_username)
      else
        Repo.get_by(User, username: email_or_username)
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

  # Basic email format validation
  defp is_valid_email?(string) do
    Regex.match?(~r/^[^\s]+@[^\s]+\.[^\s]+$/, string)
  end

  # Fetch user by email
  def get_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  # Fetch user by id (safe and bang versions)
  def get_by_id(id), do: Repo.get(User, id)
  def get_by_id!(id), do: Repo.get!(User, id)

  # Get or create user by OAuth provider data
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

  # Update username
  def update_username(%User{} = user, attrs) do
    user
    |> User.username_changeset(attrs)
    |> Repo.update()
  end

  # --- REFRESH TOKEN FUNCTIONS ---

  # Hash refresh token with sha256 + base64
  defp hash_token(token) do
    :crypto.hash(:sha256, token) |> Base.encode64()
  end

  # Create and store refresh token with expiration
  def create_refresh_token(user, token, expires_at \\ nil) do
    expires_at =
      expires_at ||
        DateTime.utc_now()
        |> DateTime.add(@refresh_token_ttl_days * 86400, :second)

    %RefreshToken{}
    |> RefreshToken.changeset(%{
      user_id: user.id,
      token_hash: hash_token(token),
      expires_at: expires_at
    })
    |> Repo.insert()
  end

  # Get a valid, not revoked, non-expired refresh token
  def get_valid_refresh_token(token) do
    token_hash = hash_token(token)

    Repo.one(
      from rt in RefreshToken,
        where:
          rt.token_hash == ^token_hash and
            rt.revoked == false and
            rt.expires_at > ^DateTime.utc_now(),
        preload: [:user]
    )
  end

  # Revoke refresh token by setting revoked: true
  def revoke_refresh_token(token) do
    token_hash = hash_token(token)

    from(rt in RefreshToken, where: rt.token_hash == ^token_hash)
    |> Repo.update_all(set: [revoked: true])
    |> case do
      {count, _} when count > 0 -> {:ok, count}
      _ -> {:error, :not_found}
    end
  end
end
