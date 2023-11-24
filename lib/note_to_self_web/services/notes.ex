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

  def acquire_lock(note_id, user) do
    note = get_note(note_id)
    if !note do
      {:error, :not_found}
    end
    if permission_to_edit(note, user) do
      {:error, :unauthorized}
    end
    if (check_lock(note, user)) do
      note
      |> Note.add_lock_changeset(%{locked_ts: NaiveDateTime.utc_now(), locked_by: user.id})
      |> Repo.update()
      IO.puts(note.locked_ts)

      {:ok, note}
    else
      {:error, :locked}
    end
  end

  defp permission_to_edit(note, user) do
    note_user_role = get_note_user_role(note.id, user.id)
    if !note_user_role || (note_user_role.role != :admin && note_user_role.role != :editor) do
      false
    else
      true
    end
  end

  defp check_lock(note, user) do
    if (note.locked_by && note.locked_by != user.id) do
      false
    else
      true
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
