defmodule ChatApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    # Disable the default auto-incrementing integer primary key that Ecto creates automatically.
    # We want to use UUIDs as the primary key because CockroachDB handles UUIDs well and they're globally unique.
    create table(:users, primary_key: false) do
      # Add an :id column of type UUID that acts as the primary key.
      # We set a default value that uses CockroachDB's built-in function gen_random_uuid() to auto-generate UUIDs on insert.
      # This ensures that when you insert a new user, you don't have to supply the ID manually.
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")

      # Add required user fields with NOT NULL constraints.
      # User's email, required and unique
      add :email, :string, null: false
      # Add username field, required and unique
      # User's username, required and unique
      add :username, :string, null: false

      # Hashed password column.
      # We make this nullable so OAuth-only users can exist without a password initially.
      add :hashed_password, :string, null: true

      # New fields for OAuth support:
      # OAuth provider name (e.g., "google")
      add :provider, :string, null: true
      # Unique ID from OAuth provider
      add :provider_uid, :string, null: true

      # Add timestamp columns for record creation and updates.
      # CockroachDB's Ecto adapter uses "created_at" instead of the default "inserted_at" for the insert timestamp.
      # To keep Ecto and the database in sync, explicitly set inserted_at: :created_at.
      # Also set updated_at to :updated_at for clarity and use UTC datetime for consistent timezone handling.
      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime)
    end

    # Create a unique index on the email column to enforce uniqueness at the database level,
    # preventing duplicate email addresses from being inserted.
    create unique_index(:users, [:email])

    # Create unique index on username to prevent duplicates
    create unique_index(:users, [:username])

    # Ensure a given provider+provider_uid combo only appears once
    create unique_index(:users, [:provider, :provider_uid])
  end
end
