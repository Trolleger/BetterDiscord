defmodule ChatApp.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication:
  - Uses user ID as subject in token.
  - Loads user resource from token claims when verifying.
  """

  use Guardian, otp_app: :chat_app
  alias ChatApp.Accounts

  @doc """
  Returns the user ID as the subject string for the JWT token.
  """
  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  @doc """
  Fetches user resource from token claims.

  This is called by Guardian during token verification.

  Includes debug logs:
  - Prints user ID from token
  - Prints result of user fetch from DB
  """
  def resource_from_claims(%{"sub" => id}) do
    IO.inspect(id, label: "Token subject user id")
    user = Accounts.get_by_id(id)
    IO.inspect(user, label: "User fetched from DB")

    case user do
      nil -> {:error, :resource_not_found}
      _ -> {:ok, user}
    end
  end
end
