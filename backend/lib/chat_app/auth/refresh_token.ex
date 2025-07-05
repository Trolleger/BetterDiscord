defmodule ChatApp.Auth.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "refresh_tokens" do
    field :token_hash, :string
    field :revoked, :boolean, default: false
    field :expires_at, :utc_datetime_usec

    belongs_to :user, ChatApp.Auth.User, type: :binary_id

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
  end

  def changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:user_id, :token_hash, :revoked, :expires_at])
    |> validate_required([:user_id, :token_hash, :expires_at])
    |> unique_constraint(:token_hash)
  end
end
