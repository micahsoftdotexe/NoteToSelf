defmodule NotesToSelf.Auth.CookieTokenValidator do
  import Plug.Conn
  alias Guardian.Plug.Pipeline

  @behaviour Plug
  @impl Plug
  def init(opts), do: opts
  @impl Plug
  def call(conn, opts) do
    relaxed = get_relax(opts)

    with {:ok, token} <- get_token_from_cookie(conn, opts),
         module <- Pipeline.fetch_module!(conn, opts),
         {:ok, claims} <- Guardian.decode_and_verify(module, token, %{}, opts) do
      conn
      |> Guardian.Plug.put_current_token(token, key: "default")
      |> Guardian.Plug.put_current_claims(claims, key: "default")
    else
      _error -> return_error(conn, relaxed)
    end
  end

  defp get_token_from_cookie(conn, opts) do
    key = Keyword.get(opts, :key, "token")
    token = conn.req_cookies[key]
    if token, do: {:ok, token}, else: :no_token_found
  end

  defp get_relax(opts) do
    Keyword.get(opts, :relax, false)
  end

  defp return_error(conn, relaxed) do
    if !relaxed do
      conn
      |> send_resp(401, Jason.encode!("Could not validate token"))
      |> halt()
    else
      conn
    end
  end
end
