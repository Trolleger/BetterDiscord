defmodule ChatApp.Repo.Migrations.CreateRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens, primary_key: false) do
      # UUID primary key with default generated UUID using pgcrypto extension
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")

      # Foreign key reference to users table with UUID type, cascade delete on user removal
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      # Hashed token string for the refresh token
      add :token_hash, :string, null: false

      # Boolean flag indicating if token is revoked or not
      add :revoked, :boolean, default: false, null: false

      # Expiry timestamp with microsecond precision
      add :expires_at, :utc_datetime_usec, null: false

      # Timestamps with microsecond precision using default inserted_at and updated_at column names
      timestamps(type: :utc_datetime_usec)
    end

    # Index to optimize lookups by token hash
    create index(:refresh_tokens, [:token_hash])

    # Index to optimize queries filtering by user_id
    create index(:refresh_tokens, [:user_id])
  end
end
