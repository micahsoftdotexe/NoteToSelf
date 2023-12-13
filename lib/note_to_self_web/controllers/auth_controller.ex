defmodule NoteToSelfWeb.AuthController do
  use NoteToSelfWeb, :controller
  alias NoteToSelf.Auth.{User, Token, Service}

  action_fallback NoteToSelfWeb.FallbackController

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, response} <- Service.login(email, password) do
      auth_login_response(conn, response)
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, response} <- Service.login_username(username, password) do
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
    if (resource && resource.is_admin) || !User.get_admin_user() do
      params = if !User.get_admin_user(), do: Map.put(params, "is_admin", true), else: params

      with {:ok, user} <- Service.register_user(params) do
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
    |> send_resp(200, Jason.encode!(resource.id))
  end

  def refresh(conn, _) do
    resource = Token.Plug.current_resource(conn)
    with {:ok, response} <- Service.refresh(resource) do
      auth_login_response(conn, response)
    end
  end

  def disable(conn, %{"user_id" => user_id}) do
    resource = Token.Plug.current_resource(conn)
    if resource.id == user_id || resource.is_admin do
      with {:ok, _response} <- Service.disable(user_id) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!("Disabled user #{user_id}"))
      end
    else
      {:error, :unauthorized}
    end
  end

  def enable(conn, %{"user_id" => user_id}) do
    resource = Token.Plug.current_resource(conn)
    if resource.is_admin do
      with {:ok, _response} <- Service.enable(user_id) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!("Enabled user #{user_id}"))
      end
    else
      {:error, :unauthorized}
    end
  end

  def find(conn, %{"identifying_info" => identifying_info}) do
    resource = Token.Plug.current_resource(conn)
    if resource.is_admin do
      with {:ok, user} <- Service.find(identifying_info) do
        conn
        |> put_status(200)
        |> put_view(json: NoteToSelfWeb.Dtos.User)
        |> render("show.json", user: user)
      end
    else
      {:error, :unauthorized}
    end
  end

  def test(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!("Successful!"))
  end
end
