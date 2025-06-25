defmodule ChatApp.Guardian.AuthPipeline do
  @moduledoc """
  Guardian pipeline plug for protecting API routes requiring authentication.

  - Verifies access token from Authorization header
  - Ensures user is authenticated
  - Loads user resource into connection assigns
  """

  use Guardian.Plug.Pipeline,
    otp_app: :chat_app,
    module: ChatApp.Guardian,
    error_handler: ChatApp.Guardian.AuthErrorHandler

  # Verify token in header with expected claim type "access"
  plug Guardian.Plug.VerifyHeader, claims: %{typ: "access"}, scheme: "Bearer"

  # Enforce that the token is present and valid
  plug Guardian.Plug.EnsureAuthenticated

  # Load user resource into conn.assigns
  plug Guardian.Plug.LoadResource, ensure: true
end
