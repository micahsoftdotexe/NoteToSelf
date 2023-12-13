defmodule NoteToSelf.Notes.Note do
  import Ecto.Query
  alias NoteToSelf.Repo
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "notes" do
    field :title, :string
    field :content, :string
    field :locked_ts, :naive_datetime
    field :locked_by, :binary_id
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

  def add_lock_changeset(note, attrs) do
    note
    |> cast(attrs, [:locked_ts, :locked_by])
  end

  def edit_changeset(note, attrs) do
    note
    |> cast(attrs, [:title, :content])
  end

  def get_notes_for_user(user) do
    query = from n in __MODULE__,
    inner_join: unr in NoteToSelf.Notes.UserNoteRole, on: n.id == unr.note_id,
    where: unr.user_id == ^user.id
    notes = Repo.all(query)
    {:ok, notes}
  end

  def get_note(id) do
    Repo.get(__MODULE__, id)
  end
end
