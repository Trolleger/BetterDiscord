defmodule ChatApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    # Create the 'users' table with these columns:
    create table(:users) do
      add :first_name, :string, null: false        # User’s first name
      add :last_name, :string, null: false         # User’s last name
      add :email, :string, null: false              # User’s email (we’ll make this unique)
      add :password, :string, null: false           # User’s password (you’ll hash this later!)

      timestamps(type: :utc_datetime)               # Automatically adds inserted_at and updated_at columns with UTC timestamps
    end

    # Enforce email uniqueness at the database level — no duplicates allowed
    create unique_index(:users, [:email])
  end
end
