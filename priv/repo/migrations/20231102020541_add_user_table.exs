defmodule NoteToSelf.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_active, :boolean
      add :email, :string, null: false
      add :hashed_password, :string
      add :username, :string, null: false
      add :is_admin, :boolean, null: false, default: false
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
