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
        delete_csrf_token()
        csrf = get_csrf_token()
        conn
        |> put_resp_cookie("access_token", jwt, [http_only: true, secure: true])
        |> put_resp_cookie("refresh_token", cookieJWT, [http_only: true, secure: true])
        |> put_resp_content_type("application/json")
        |> fetch_session()
        |> put_session(:_csrf_token, Process.get(:plug_unmasked_csrf_token))
        |> send_resp(200, Jason.encode!(%{csrf: csrf}))
    end
  end
  def register(conn, %{"user" => params}) do
    resource = Token.Plug.current_resource(conn)
    if (resource && resource.is_admin) || !Auth.get_admin_user() do
      params = if !Auth.get_admin_user() do
        Map.put(params, "is_admin", true)
      else
        params
      end
      with {:ok, user} <- Auth.register_user(params) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!("Created user #{user.username}"))
      end
    else
      {:error, :unauthorized}

    end
  end

  def show(conn, _) do
    resource = Token.Plug.current_resource(conn)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(resource.email))
  end

  def refresh(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("Refreshed a token!"))
  end

  def test(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("Successful!"))
  end
end
