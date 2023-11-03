defmodule NoteToSelfWeb.AuthController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.{User,Token}
  alias NoteToSelf.Auth
  alias NoteToSelf.Repo

  def login(conn, %{"email" => email, "password" => password}) do
    case Auth.validate_email_and_pass(email, password) do
      {:ok, result} -> get_token(conn, result)
      {:error, _error} -> conn |> put_status(400)
    end
  end
  defp get_token(conn, user) do

    case Token.encode_and_sign(user) do
      {:ok, jwt, _full_claims} -> conn |> put_resp_content_type("application/json")|> send_resp(200, Jason.encode!(%{token: jwt}))
      {:error, _error} -> conn |> put_status(400)
    end
    # {:ok, jwt, _full_claims} = Token.encode_and_sign(user)


    # conn
    # |> put_resp_content_type("application/json")
    # |> send_resp(200, Jason.encode!(%{token: jwt}))
  end
  def register(conn, %{"user" => params}) do
    with {:ok, user} <- Auth.register_user(params) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!("Registered"))
    end
  end
end
