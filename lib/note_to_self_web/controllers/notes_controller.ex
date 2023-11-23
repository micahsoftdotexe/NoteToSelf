defmodule NoteToSelfWeb.NotesController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.Token
  alias NoteToSelfWeb.Service.Notes


  action_fallback NoteToSelfWeb.FallbackController
  def create(conn, %{"note" => %{"title" => title}}) do
    resource = Token.Plug.current_resource(conn)
    if (resource) do
      with(
        {:ok, %{note: note, user_note_role: _}} <- Notes.create_note_and_inital_role(resource, title)

      )do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(note.id))
      end

    else
      {:error, :not_logged_in}
    end
  end
end
