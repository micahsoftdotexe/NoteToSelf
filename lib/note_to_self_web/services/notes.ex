defmodule NoteToSelfWeb.Service.Notes do
  alias NoteToSelf.Notes.{Note, UserNoteRole}
  alias NoteToSelf.Repo
  def create_note_and_role(user, title) do
    with(
      {:ok, note} <- create_note(title),
      {:ok, user_note_role} <- create_user_note_role(user, note, :admin)
    ) do
      {:ok, %{note: note, user_note_role: user_note_role}}
    end
  end

  def get_note_user_role(note_id, user_id) do
    Repo.get_by(UserNoteRole, note_id: note_id, user_id: user_id)
  end

  def get_note(id) do
    Repo.get(Note, id)
  end

  defp create_note(title) do
    %Note{}
    |> Note.initial_creation_changeset(%{title: title, content: ""})
    |> Repo.insert()
  end

  defp create_user_note_role(user, note, role) do
    %UserNoteRole{}
    |> UserNoteRole.creation_changeset(%{role: role, note_id: note.id, user_id: user.id})
    |> Repo.insert()
  end
end
