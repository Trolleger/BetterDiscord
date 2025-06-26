defmodule ChatApp.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication:
  - Uses user ID as subject
  - Loads user resource from token claims
  """
  use Guardian, otp_app: :chat_app
  alias ChatApp.Accounts

  # Subject for token: user ID as string
  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  # Fetch user resource from token claims
  def resource_from_claims(%{"sub" => id}) do
    resource = Accounts.get_by_id!(id)
    {:ok, resource}
  end
end
