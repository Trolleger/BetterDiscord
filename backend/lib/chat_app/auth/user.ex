defmodule ChatApp.Auth.User do
  @moduledoc "Ecto schema and changesets for users (email/password + optional OAuth)."
  use Ecto.Schema
  import Ecto.Changeset
  alias Bcrypt

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :username, :string
    field :hashed_password, :string
    field :provider, :string
    field :provider_uid, :string
    field :password, :string, virtual: true

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime)
  end

  @doc "Manual registration (email/password)"
  def registration_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:username, min: 3, max: 30)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_hashed_password()
  end

  @doc "OAuth login (first-time or link)"
  def oauth_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:email, :provider, :provider_uid, :username])
    |> validate_required([:email, :provider, :provider_uid])
    |> unique_constraint(:email)
    |> unique_constraint(:provider_uid)
  end

  @doc "OAuth user sets a password later"
  def set_password_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> put_hashed_password()
  end

  @doc "Used when user updates their username"
  def username_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> validate_length(:username, min: 3, max: 30)
    |> unique_constraint(:username)
  end

  defp put_hashed_password(changeset) do
    if pw = get_change(changeset, :password) do
      change(changeset, hashed_password: Bcrypt.hash_pwd_salt(pw, log_rounds: 12))
    else
      changeset
    end
  end
end
