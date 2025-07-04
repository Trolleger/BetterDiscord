defmodule ChatApp.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  # ✅ This line is the fix — check the session instead of headers
  plug Guardian.Plug.VerifySession, claims: %{typ: "access"}

  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  # That ensure: true doesn't assign :current_user, it only ensures a resource is present and halts if not.
  #  It does not do what you think — and that’s why conn.assigns[:current_user] is still nil. So be mindful of taht

end
