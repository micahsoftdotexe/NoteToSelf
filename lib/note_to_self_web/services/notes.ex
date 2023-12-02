defmodule NoteToSelfWeb.Service.Notes do
  import Ecto.Query
  alias NoteToSelf.Notes.{Note, UserNoteRole}
  alias NoteToSelf.Auth.User
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
    else
      with(
        {:ok} <- permission_to_edit(note, user),
        {:ok} <- check_lock(note, user)
      ) do
        note
        |> Note.add_lock_changeset(%{locked_ts: NaiveDateTime.utc_now(), locked_by: user.id})
        |> Repo.update()
      end
    end

  end
  def release_lock(note_id, user) do
    note = get_note(note_id)
    if !note do
      {:error, :not_found}
    else
      with(
        {:ok} <- permission_to_edit(note, user),
        {:ok} <- check_lock(note, user)
      ) do
        note
        |> Note.add_lock_changeset(%{locked_ts: nil, locked_by: nil})
        |> Repo.update()
      end
    end
  end

  def list_notes(user) do
    query = from n in Note,
    inner_join: unr in UserNoteRole, on: n.id == unr.note_id,
    where: unr.user_id == ^user.id
    notes = Repo.all(query)
    {:ok, notes}
  end

  @spec edit_note(any(), any(), any()) :: any()
  def edit_note(note_id, user, attrs) do
    note = get_note(note_id)
    if !note do
      {:error, :not_found}
    else
      with(
        {:ok} <- permission_to_edit(note, user),
        {:ok} <- check_lock(note, user)
      ) do
        note
        |> Note.edit_changeset(attrs)
        |> Note.add_lock_changeset(%{locked_ts: NaiveDateTime.utc_now(), locked_by: user.id})
        |> Repo.update()
      end
    end
  end

  def delete_note(note_id, user) do
    note = get_note(note_id)
    if !note do
      {:error, :not_found}
    else
      with {:ok} <- permission_to_delete(note, user) do
        Repo.delete(note)
      end
    end
  end

  defp permission_to_delete(note, user) do
    note_user_role = get_note_user_role(note.id, user.id)
    if !note_user_role || (note_user_role.role != :admin) do
      {:error, :fobidden}
    else
      {:ok}
    end
  end

  defp permission_to_edit(note, user) do
    note_user_role = get_note_user_role(note.id, user.id)
    if !note_user_role || (note_user_role.role != :admin && note_user_role.role != :editor) do
      {:error, :fobidden}
    else
      {:ok}
    end
  end

  defp check_lock(note, user) do
    if (note.locked_by && note.locked_by != user.id && (note.locked_ts && !check_lock_timeout(note.locked_ts)) ) do
      {:error, :forbidden, "Note locked by #{Repo.get(User, note.locked_by).username}"}
    else
      {:ok}
    end
  end

  defp check_lock_timeout(locked_ts) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), locked_ts, :minute) >= 30
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
