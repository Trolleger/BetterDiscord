defmodule ChatApp.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  # Verify JWT from Authorization header, expect "access" token type
  plug Guardian.Plug.VerifyHeader,
    claims: %{typ: "access"},
    scheme: "Bearer"

  # If no token in header, check session cookie for access token
  plug Guardian.Plug.VerifySession,
    claims: %{typ: "access"}

  # Load the user resource if token is valid
  plug Guardian.Plug.LoadResource

  # Ensure authentication is present, otherwise halt with 401
  plug Guardian.Plug.EnsureAuthenticated
end
