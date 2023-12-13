defmodule NoteToSelf.Notes.Service do
  alias NoteToSelf.Notes.{Note, UserNoteRole}
  alias NoteToSelf.Auth.User
  alias NoteToSelf.Repo
  @spec create_note_and_role(any(), any()) :: any()
  def create_note_and_role(user, title) do
    with(
      {:ok, note} <- create_note(title),
      {:ok, user_note_role} <- create_user_note_role(user, note, :admin)
    ) do
      {:ok, %{note: note, user_note_role: user_note_role}}
    end
  end

  def acquire_lock(note_id, user) do
    note = Note.get_note(note_id)
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
    note = Note.get_note(note_id)
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
    Note.get_notes_for_user(user)
  end

  @spec edit_note(any(), any(), any()) :: any()
  def edit_note(note_id, user, attrs) do
    note = Note.get_note(note_id)
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
    note = Note.get_note(note_id)
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

  def add_user_note_role(user, note, role, created_by) do
    if get_note_user_role(note.id, created_by.id) && get_note_user_role(note.id, created_by.id).role == :admin do
      create_user_note_role(user, note, role)
    else
      {:error, :forbidden, "Only note admin can add role"}
    end
  end

  def delete_user_note_role(note_id, user, note, created_by) do
    if (get_note_user_role(note_id, created_by.id) && get_note_user_role(note_id, created_by.id).role == :admin) || user == created_by do
      delete_user_note_role(user, note)
    else
      {:error, :forbidden, "Only note admin can remove role"}
    end
  end


  defp create_user_note_role(user, note, role) do
    %UserNoteRole{}
    |> UserNoteRole.creation_changeset(%{role: role, note_id: note.id, user_id: user.id})
    |> Repo.insert()
  end
  defp delete_user_note_role(user, note) do
    user_note_role = get_note_user_role(note.id, user.id)
    if user_note_role do
      with {:ok, _} <- Repo.delete(user_note_role) do
        {:ok}
      else
        {:error, _} -> {:error, :not_found}
      end

    else
      {:error, :not_found}
    end
  end
  defp create_note(title) do
    %Note{}
    |> Note.initial_creation_changeset(%{title: title, content: ""})
    |> Repo.insert()
  end
end
