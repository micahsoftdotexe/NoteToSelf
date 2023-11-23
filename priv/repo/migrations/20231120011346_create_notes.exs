defmodule NoteToSelf.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :title, :string, size: 128
      add :content, :string
      add :lock_ts, :naive_datetime
      add :lock_by, :id
      timestamps()
    end

    create table(:user_note_roles, primary_key: false) do
      add :role, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), primary_key: true
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), primary_key: true
      timestamps()
    end
  end
end
