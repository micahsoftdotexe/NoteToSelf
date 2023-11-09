defmodule NoteToSelfWeb.AuthController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.{Token}
  alias NoteToSelf.Auth

  action_fallback NoteToSelfWeb.FallbackController

  def login(conn, %{"email" => email, "password" => password}) do
    with(
      {:ok, user} <- Auth.authenticate(email, password),
      {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, ttl: {1, :minute}),
      {:ok, cookieJWT, _full_claims} <- Token.encode_and_sign(user, %{}, [ttl: {1, :week}, type: :refresh])) do
        conn
        |> put_resp_cookie("refresh_token", cookieJWT, http_only: true)
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{token: jwt}))
    end
  end
  def register(conn, %{"user" => params}) do
    with {:ok, user} <- Auth.register_user(params) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!("Created user #{user.username}"))
    end
  end

  def show(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("You have a valid token!"))
  end

  def refresh(conn, _) do

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("Refreshed a token!"))
  end
end
