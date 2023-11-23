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

  defp create_note(title) do
    %Note{}
    |> Note.initial_creation_changeset(%{title: title, content: ""})
    |> Repo.insert()
  end

  defp create_user_note_role(user, note, role) do
    # IO.puts(note)
    %UserNoteRole{}
    |> UserNoteRole.creation_changeset(%{role: role, note_id: note.id, user_id: user.id})
    |> Repo.insert()
    # user_note_role = %NoteToSelf.Notes.UserNoteRole{
    #   user_id: user.id,
    #   note_id: note.id,
    #   role: to_string(role)
    # }
    # Repo.insert(user_note_role)
  end
end
