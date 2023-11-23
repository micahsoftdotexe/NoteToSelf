defmodule NoteToSelfWeb.NotesController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.Token
  alias NoteToSelfWeb.Service.Notes


  action_fallback NoteToSelfWeb.FallbackController
  def create(conn, %{"note" => %{"title" => title}}) do
    resource = Token.Plug.current_resource(conn)
    if (resource) do
      with(
        {:ok, %{note: note, user_note_role: _}} <- Notes.create_note_and_role(resource, title)

      )do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(note.id))
      end

    else
      {:error, :not_logged_in}
    end
  end
  def show(conn, %{"id" => id}) do
    resource = Token.Plug.current_resource(conn)
    if (resource && Notes.get_note_user_role(id, resource.id)) do
      if Notes.get_note(id) do
        conn
        |> put_status(200)
        |> put_view(json: NoteToSelfWeb.Dtos.Note)
        |> render("show.json", note: Notes.get_note(id))
      else
        {:error, :not_found}
      end
      # with {:ok, note} <- Notes.get_note(id) do
      #   IO.puts("Here")
      #   conn
      #   |> put_status(200)
      #   |> put_view(json: NoteToSelfWeb.Dtos.Note)
      #   |> render("show.json", note: note)
      # end
    end
  end
end
