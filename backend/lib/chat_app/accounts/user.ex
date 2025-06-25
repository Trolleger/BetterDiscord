defmodule ChatApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bcrypt

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :username, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :provider, :string
    field :provider_uid, :string

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:password, min: 8)
    |> validate_length(:username, max: 30)
    |> encrypt_and_put_password()
  end

  def oauth_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :provider, :provider_uid])
    |> validate_required([:email, :provider, :provider_uid])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> unique_constraint(:provider_uid)
  end

  def username_changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> validate_format(:username, ~r/^\w{3,20}$/)
    |> unique_constraint(:username)
  end

  defp encrypt_and_put_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password, log_rounds: 12))
    end
  end
end
