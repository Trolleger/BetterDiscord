defmodule ChatApp.Guardian.AuthPipeline.Optional do
  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  # Verify JWT from Authorization header, expect "access" token type
  plug Guardian.Plug.VerifyHeader,
    claims: %{typ: "access"},
    scheme: "Bearer"

  # Check session cookie for access token as fallback
  plug Guardian.Plug.VerifySession,
    claims: %{typ: "access"}

  # Load the user resource if token is valid
  plug Guardian.Plug.LoadResource

  # NO EnsureAuthenticated here — allows optional auth for public or refresh routes
end
