defmodule ChatApp.Guardian.AuthPipeline.Optional do
  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  require Logger

  # Verify JWT from Authorization header, expect "access" token type, don't halt if missing
  plug Guardian.Plug.VerifyHeader,
    claims: %{typ: "access"},
    scheme: "Bearer",
    halt: false

  # Check session cookie for access token as fallback, don't halt if missing
  plug Guardian.Plug.VerifySession,
    claims: %{typ: "access"},
    halt: false

  # Load the user resource if token is valid, allow blank (no user)
  plug Guardian.Plug.LoadResource, allow_blank: true

  # No EnsureAuthenticated here — allows optional auth for public or refresh routes
end
