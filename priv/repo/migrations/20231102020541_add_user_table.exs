defmodule NoteToSelf.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
      create table(:users) do
        add :is_active, :boolean
        add :email, :string, null: false
        add :hashed_password, :string
        add :username, :string, null: false
        timestamps()
      end
      create unique_index(:users, [:email])
      create unique_index(:users, [:username])
  end
end
