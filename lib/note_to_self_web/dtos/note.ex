defmodule NoteToSelfWeb.Dtos.Note do
  def show(%{note: note}) do
    %{id: note.id, title: note.title, content: note.content, locked_by: note.locked_by, locked_ts: note.locked_ts}
  end
end
