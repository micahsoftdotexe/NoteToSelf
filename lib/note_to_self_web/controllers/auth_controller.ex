defmodule NoteToSelfWeb.AuthController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.{Token}
  alias NoteToSelfWeb.Service.Auth

  action_fallback NoteToSelfWeb.FallbackController

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, response} <- Auth.login(email, password) do
      auth_login_response(conn, response)
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, response} <- Auth.login_username(username, password) do
      auth_login_response(conn, response)
    end
  end

  defp auth_login_response(conn, %{:access_token => access_token, :refresh_token => refresh_token}) do
    delete_csrf_token()
    csrf = get_csrf_token()

    conn
    |> put_resp_cookie("access_token", access_token, http_only: true, secure: true)
    |> put_resp_cookie("refresh_token", refresh_token, http_only: true, secure: true)
    |> put_resp_content_type("application/json")
    |> fetch_session()
    |> put_session(:_csrf_token, Process.get(:plug_unmasked_csrf_token))
    |> send_resp(200, Jason.encode!(%{csrf: csrf}))
  end

  def register(conn, %{"user" => params}) do
    resource = Token.Plug.current_resource(conn)

    # TODO: Replace the following check if you want anyone to register to application. It will allow the first user created to be an admin
    if (resource && resource.is_admin) || !Auth.get_admin_user() do
      params = if !Auth.get_admin_user(), do: Map.put(params, "is_admin", true), else: params

      with {:ok, user} <- Auth.register_user(params) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!("Created user #{user.username}"))
      end
    else
      {:error, :cannot_create_user}
    end
  end

  def show(conn, _) do
    resource = Token.Plug.current_resource(conn)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(resource.email))
  end

  def refresh(conn, _) do
    resource = Token.Plug.current_resource(conn)
    with {:ok, response} <- Auth.refresh(resource) do
      auth_login_response(conn, response)
    end
  end

  def test(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("Successful!"))
  end
end
