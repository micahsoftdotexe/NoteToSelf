defmodule NoteToSelf.Repo do
  use Ecto.Repo,
    otp_app: :note_to_self,
    adapter: Ecto.Adapters.Postgres
end
