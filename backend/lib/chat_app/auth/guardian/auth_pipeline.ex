# lib/chat_app_web/pipelines/auth_pipeline.ex
defmodule ChatApp.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  # First try to pull an “access” JWT out of the Authorization header
  plug Guardian.Plug.VerifyHeader,
    claims: %{typ: "access"},
    scheme: "Bearer"

  # If none there, try to pull it out of the session cookie
  plug Guardian.Plug.VerifySession,
    claims: %{typ: "access"}

  # If we’ve got a valid token, load the user into conn.assigns.current_resource
  plug Guardian.Plug.LoadResource

  # Finally, bail out if there’s no valid token
  plug Guardian.Plug.EnsureAuthenticated
end
