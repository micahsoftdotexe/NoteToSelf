defmodule NoteToSelfWeb.NotesController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.Token
  alias NoteToSelf.{Notes,Auth}

  # alias NoteToSelfWeb.Service.{Auth,Notes}


  action_fallback NoteToSelfWeb.FallbackController
  def create(conn, %{"note" => %{"title" => title}}) do
    resource = Token.Plug.current_resource(conn)
    if (resource) do
      with(
        {:ok, %{note: note, user_note_role: _}} <- Notes.Service.create_note_and_role(resource, title)

      )do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(note.id))
      end

    else
      {:error, :not_logged_in}
    end
  end
  def delete(conn, %{"id" => id}) do
    resource = Token.Plug.current_resource(conn)
    with {:ok} <- Notes.Service.delete_note(id, resource) do
      conn
      |> put_status(200)
      |> send_resp(200, "Successfully deleted")
    end
  end
  def edit(conn, %{"id" => id, "note" => note }) do
    resource = Token.Plug.current_resource(conn)
    with {:ok, note} <- Notes.Service.edit_note(id, resource, note) do
      conn
      |> put_status(200)
      |> put_view(json: NoteToSelfWeb.Dtos.Note)
      |> render("show.json", note: note)
    end
  end
  def list(conn, _params) do
    resource = Token.Plug.current_resource(conn)
    with {:ok, notes} <- Notes.Service.list_notes(resource) do
      conn
      |> put_status(200)
      |> put_view(json: NoteToSelfWeb.Dtos.Note)
      |> render("list.json", notes: notes)
    end
  end
  def show(conn, %{"id" => id}) do
    resource = Token.Plug.current_resource(conn)
    if (resource && Notes.Service.get_note_user_role(id, resource.id)) do
      if Notes.Note.get_note(id) do
        conn
        |> put_status(200)
        |> put_view(json: NoteToSelfWeb.Dtos.Note)
        |> render("show.json", note: Notes.Note.get_note(id))
      else
        {:error, :not_found}
      end
    end
  end

  def fetch_lock(conn, %{"id" => id}) do
    user = Token.Plug.current_resource(conn)
    with {:ok, note} <- Notes.Service.acquire_lock(id, user) do
      conn
      |> put_status(200)
      |> put_view(json: NoteToSelfWeb.Dtos.Note)
      |> render("show.json", note: note)

    end
  end
  def release_lock(conn, %{"id" => id}) do
    user = Token.Plug.current_resource(conn)
    with {:ok, note} <- Notes.Service.release_lock(id, user) do
      conn
      |> put_status(200)
      |> put_view(json: NoteToSelfWeb.Dtos.Note)
      |> render("show.json", note: note)
    end
  end
  def create_user_note_role(conn, %{"username" => username, "id" => id, "role" => role}) do
    resource = Token.Plug.current_resource(conn)
    user = Auth.User.get_user_by_username(username)
    note = Notes.Note.get_note(id)
    if  (user && note) do
      create_role(user, note, role, resource, conn)
    else
      {:error, :not_found}
    end
  end
  def create_user_note_role(conn, %{"email" => email, "id" => id, "role" => role}) do
    resource = Token.Plug.current_resource(conn)
    user = Auth.User.get_user_by_email(email)
    note = Notes.Note.get_note(id)
    if  (user && note) do
      create_role(user, note, role, resource, conn)
    else
      {:error, :not_found}
    end
  end
  def delete_user_note_role(conn, %{"user_id" => user_id, "id" => id}) do
    resource = Token.Plug.current_resource(conn)
    user = Auth.User.get_user(user_id)
    note = Notes.Note.get_note(id)
    with {:ok} <- Notes.Service.delete_user_note_role(id, user, note, resource) do
      conn
      |> put_status(200)
      |> put_view(json: NoteToSelfWeb.Dtos.Note)
      |> render("show.json", note: note)
    end
  end

  defp create_role(user, note, role, created_by, conn) do
    with {:ok, _user_note_role} <- Notes.Service.add_user_note_role(user, note, String.to_existing_atom(role), created_by) do
      conn
      |> put_status(200)
      |> put_view(json: NoteToSelfWeb.Dtos.Note)
      |> render("show.json", note: note)
    end
  end
end
