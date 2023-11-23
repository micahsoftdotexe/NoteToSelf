defmodule NoteToSelf.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset
  schema "notes" do
    field :title, :string
    field :content, :string
    field :lock_ts, :naive_datetime
    field :lock_by, :id
    has_many :user_note_roles, NoteToSelf.Notes.UserNoteRole
    timestamps()
  end

  def changeset(note, attrs) do
    note
    |> cast(attrs, [:title, :content, :lock_ts, :lock_by])
  end
  def initial_creation_changeset(note, attrs) do
    note
    |> cast(attrs, [:title, :content])
  end

end