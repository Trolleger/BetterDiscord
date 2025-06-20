# SessionView formats the response for session-related data like access tokens.
defmodule ChatAppWeb.SessionView do
  use ChatAppWeb, :json
  # Renders the JSON response containing the access token after login.
  def render("token.json", %{access_token: access_token}) do
    %{access_token: access_token}
  end
end
