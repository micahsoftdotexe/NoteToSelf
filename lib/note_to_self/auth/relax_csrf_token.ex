defmodule NoteToSelf.Auth.RelaxCsrfToken do
  @behaviour Plug
  @impl Plug
  def init(opts) do
    session_key = Keyword.get(opts, :session_key, "_csrf_token")
    mode = Keyword.get(opts, :with, :exception)
    allow_hosts = Keyword.get(opts, :allow_hosts, [])
    {session_key, mode, allow_hosts}
  end
  @impl Plug
  def call(conn, {session_key, mode, allow_hosts}) do
    user = Guardian.Plug.current_resource(conn)
    if user do
      Plug.CSRFProtection.call(conn, {session_key, mode, allow_hosts})
    else
      conn
    end
  end
end
