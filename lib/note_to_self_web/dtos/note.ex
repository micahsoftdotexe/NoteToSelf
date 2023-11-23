defmodule NoteToSelfWeb.Dtos.Note do
  def show(%{note: note}) do
    %{id: note.id, title: note.title, content: note.content}
  end
end
