defmodule ChatApp.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{typ: "access"}, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
