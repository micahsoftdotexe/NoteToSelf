defmodule NoteToSelf.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :note_to_self,
  module: NoteToSelf.Auth.Token,
  error_handler: NoteToSelf.Auth.AuthErrorHandler

  # plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
