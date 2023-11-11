defmodule NoteToSelfWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  alias NoteToSelfWeb.Dtos.{ErrorJSON}
  use NoteToSelfWeb, :controller

  def call(conn, {:ok, response}) do
    conn
    |> put_status(200)
    |> send_resp(200, Jason.encode!(response))
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ErrorJSON)
    |> render("ecto.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(:"404")
  end

  # def call(conn, {:error, :unauthorized}) do
  #   conn
  #   |> put_status(401)
  # end

  def call(conn, {:error, :invalid_login}) do
    IO.puts("Within Call")
    conn
    |> put_status(401)
    |> put_view(json: ErrorJSON)
    |> render("login.json")
  end
end
