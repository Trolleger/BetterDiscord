defmodule ChatAppWeb.UserController do
  use ChatAppWeb, :controller

  alias ChatApp.Accounts
  alias ChatApp.Accounts.User

  action_fallback ChatAppWeb.FallbackController
  def register(conn, %{"user"=> user_params}) do
  # passes users params
  with {:ok,user} <- Accounts.create_user(user_params) do
    # With okay and user if this all goes well, we are going to continue inside of this, so we pass the connection
    conn
    |>put_status(:created)
    # It returns a 201 code on the http connection
    |>text("User succsessfully registered with email:" <> " " <> user.email)
    # What this basically does is going to do is just return the message and we pass just the  email to make sure we don't deliver a lot of information after the registration
    # since it is not YET needed
  end
end
end
# DONT WORRY ABOUT MISSING ERRORS OR SHIT LIKE THIS OR THAT WE WILL BE FIXING IT LATER
