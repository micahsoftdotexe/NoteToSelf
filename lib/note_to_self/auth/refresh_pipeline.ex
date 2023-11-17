defmodule NoteToSelf.Auth.RefreshPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :note_to_self,
    module: NoteToSelf.Auth.Token,
    error_handler: NoteToSelf.Auth.AuthErrorHandler

  # plug Guardian.Plug.VerifySession
  # plug Guardian.Plug.VerifyCookie, key: "refresh"
  plug NotesToSelf.Auth.CookieTokenValidator, key: "refresh_token"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
