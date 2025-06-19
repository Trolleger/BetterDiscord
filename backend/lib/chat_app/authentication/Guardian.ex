defmodule ChatApp.Guardian do
  # First, we create the module that we referenced in the pipeline, and add the following:
  use Guardian, otp_app: :chat_app
  # `otp_app` is the application name used to pull Guardian config from mix.exs and config files

  alias ChatApp.Accounts
  # We alias the Accounts context so we can call functions like get_by_id! below

  # subject_for_token/2 takes the user (resource) and returns a string version of their ID
  # This becomes the "sub" (subject) field in the JWT
  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  # resource_from_claims/1 does the reverse — takes the claims from the token,
  # extracts the "sub" (user ID), and returns the user from the database
  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Accounts.get_by_id!(id)
    {:ok, resource}
  end

end
