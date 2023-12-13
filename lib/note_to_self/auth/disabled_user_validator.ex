defmodule NoteToSelf.Auth.DisabledUserValidator do
  import Plug.Conn

  @behaviour Plug
  @impl Plug

  def init(opts), do: opts
  @impl Plug
  def call(conn, opts) do
    user = Guardian.Plug.current_resource(conn)
    cond do
      user && user.disabled ->
        conn |> send_resp(401, Jason.encode!("User is disabled")) |> halt()
      !user && get_relax(opts) ->
        conn
      !user && !get_relax(opts) ->
        conn
        |> send_resp(401, Jason.encode!("Could not validate token"))
        |> halt()
      true ->
        conn

    end
    # if user && user.disabled do
    #   conn |> send_resp(401, Jason.encode!("User is disabled")) |> halt()

    # else
    #   if !user && get_relax(opts) do
    #     conn
    # end
  end

  defp get_relax(opts) do
    Keyword.get(opts, :relax, false)
  end


end
