defmodule ChatApp.Guardian do
  use Guardian, otp_app: :chat_app
  alias ChatApp.Accounts

  @impl true
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_by_id(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  @impl true
  def build_claims(claims, _resource, _opts) do
    # Ensures the "typ" claim (like "access" or "refresh") is included in the token
    claims = Map.put(claims, "typ", claims["typ"] || "access")
    {:ok, claims}
  end
end
