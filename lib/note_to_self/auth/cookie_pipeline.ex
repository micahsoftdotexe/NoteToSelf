defmodule NoteToSelf.Auth.CookiePipeline do
  use Guardian.Plug.Pipeline, otp_app: :note_to_self,
  module: NoteToSelf.Auth.Token,
  error_handler: NoteToSelf.Auth.AuthErrorHandler

  # plug Guardian.Plug.VerifySession

  plug Guardian.Plug.VerifySession, [refresh_from_cookie: true, key: "refresh_token"]
  plug Guardian.Plug.EnsureAuthenticated, [claims: %{"typ" => "refresh"}, key: "refresh_token"]
  plug Guardian.Plug.LoadResource
end
