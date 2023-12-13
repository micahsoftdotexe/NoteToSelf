defmodule NoteToSelfWeb.Dtos.User do
  def show(%{user: user}) do
    %{id: user.id, email: user.email, username: user.username, is_admin: user.is_admin, disabledTS: user.disabledTS}
  end
end
