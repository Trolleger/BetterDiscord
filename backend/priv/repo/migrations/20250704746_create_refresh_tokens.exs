defmodule ChatApp.Repo.Migrations.CreateRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :token_hash, :string, null: false
      add :revoked, :boolean, default: false, null: false
      add :expires_at, :utc_datetime_usec, null: false

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
    end

    create index(:refresh_tokens, [:token_hash])
    create index(:refresh_tokens, [:user_id])
  end
end
