defmodule ChatApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    # Disable the default auto-incrementing integer primary key that Ecto creates automatically.
    # We want to use UUIDs as the primary key because CockroachDB handles UUIDs well and they’re globally unique.
    create table(:users, primary_key: false) do
      # Add an :id column of type UUID that acts as the primary key.
      # We set a default value that uses CockroachDB’s built-in function gen_random_uuid() to auto-generate UUIDs on insert.
      # This ensures that when you insert a new user, you don't have to supply the ID manually.
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")

      # Add required user fields with NOT NULL constraints.
      add :first_name, :string, null: false     # User's first name, required field
      add :last_name, :string, null: false      # User's last name, required field
      add :email, :string, null: false          # User's email, required and unique
      add :hashed_password, :string, null: false       # Hashed password, required field

      # Add timestamp columns for record creation and updates.
      # CockroachDB’s Ecto adapter uses "created_at" instead of the default "inserted_at" for the insert timestamp.
      # To keep Ecto and the database in sync, explicitly set inserted_at: :created_at.
      # Also set updated_at to :updated_at for clarity and use UTC datetime for consistent timezone handling.
      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime)
    end

    # Create a unique index on the email column to enforce uniqueness at the database level,
    # preventing duplicate email addresses from being inserted.
    create unique_index(:users, [:email])
  end
end
