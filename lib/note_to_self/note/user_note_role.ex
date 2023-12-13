defmodule NoteToSelf.Notes.UserNoteRole do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "user_note_roles" do
    belongs_to :user, NoteToSelf.Auth.User, foreign_key: :user_id, primary_key: true, type: :binary_id
    belongs_to :note, NoteToSelf.Notes.Note, foreign_key: :note_id, primary_key: true, type: :binary_id
    field :role, Ecto.Enum, values: [:admin, :viewer, :editor]
    timestamps()
  end
  def creation_changeset(user_note_role, attrs) do
    user_note_role
    |> cast(attrs, [:role, :user_id, :note_id])
  end
end
