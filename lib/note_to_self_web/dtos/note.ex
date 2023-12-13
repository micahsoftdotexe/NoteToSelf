defmodule NoteToSelfWeb.Dtos.Note do
  def show(%{note: note}) do
    %{id: note.id, title: note.title, content: note.content, locked_by: note.locked_by, locked_ts: note.locked_ts}
  end

  def list(%{notes: notes}) do
    for note <- notes, do: show(%{note: note})
  end
end
