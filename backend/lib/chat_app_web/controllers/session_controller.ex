defmodule ChatAppWeb.SessionController do
  # just like with view we want to add the look below
  use ChatAppWeb, :controller

  # And now we have to alias a couple of things
  alias ChatApp.Accounts
  alias ChatApp.Guardian

  # Alias both of these modules
  action_fallback ChatAppWeb.FallbackController
  # If something inside of this controller matches anything in fallback_controller.ex,
  # it will automatically give us back the error instead of crashing the app

  # Now we create 3 different functions. The New, The Refresh (make sure somebody is authenticated and if they are, refresh the session), and The Delete
  # (just deletes the cookies from the response so the client can handle logging out)

  # UPDATED: Changed to expect parameters under a "user" key for consistency with registration
  def new(conn, %{"user" => %{"email" => email, "password" => password}}) do
    # create a function for the controller, pass the connection, the email and the password which are going to be the values of the JSON sent from the client or from a rest client
    # And then we want to add here the following function which we created in accounts.ex (authenticate_user) which validates the password and makes sure it matches in the database and all
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute})
        # So if all of this goes well we encode and sign the token, we grab the user and encode it with a token type access, and add a life time of 15 minutes to this token
        # Access token → 15 minutes → refresh token (7 days or whatever) → Each time that somebody sends us the request we're going to use the refresh token to get the access
        # token → access token gets us the resources that we need → never going to use just one token for the entire process, would be very unsafe and all

        # Now we also create the refresh token
        {:ok, refresh_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})
        # As you can see we do the same thing but changed token time to 7 days and we call the variable something different so no conflict

        conn
        |> put_resp_cookie("ruid", refresh_token, http_only: true, secure: true, max_age: 7 * 24 * 60 * 60)
        # and finally we're going to use the connection, put the resp_cookie (add the cookie to the response) with the following name: ruid and pass the refresh token, the R means refresh
        |> put_status(:created)
        # Then you put a status of created (201)
        |> json(%{access_token: access_token})
        # and finally return JSON directly with the access token

      {:error, :unauthorized} ->
        # Wrong password
        unauthorized_response(conn)

      {:error, :not_found} ->
        # Email not found – treat same as unauthorized to avoid leaking info
        unauthorized_response(conn)
    end
  end

  # ADDED: New clause to handle missing "user" parameter structure
  def new(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing user parameters. Expected format: {\"user\": {\"email\": \"...\", \"password\": \"...\"}}"})
  end

  # helper to DRY up the 401 response
  defp unauthorized_response(conn) do
    conn
    |> put_status(401)
    |> json(%{error: "unauthorized"})
  end

  def refresh(conn, _params) do
    # fetch the refresh token from cookies
    refresh_token =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Map.from_struct()
      |> get_in([:cookies, "ruid"])
    # In this code we fetch the cookies from the connection, convert struct to map, then get the "ruid" cookie

    case Guardian.exchange(refresh_token, "refresh", "access", ttl: {15, :minute}) do
      {:ok, _old_stuff, {new_access_token, _new_claims}} ->
        conn
        |> put_status(:created)
        |> json(%{access_token: new_access_token})
        # Successfully exchanged refresh for new access token

      {:error, _reason} ->
        conn
        |> put_status(401)
        |> json(%{error: "unauthorized"})
        # Incase an error arises we send unauthorized
    end
  end

  # FINALLY we have to add the delete function that is going to help us log out our user.
  # This just clears the cookie; frontend should clear its auth state too.
  def delete(conn, _params) do
    conn
    |> delete_resp_cookie("ruid")
    # as you can see this is very simple, we pass the conn, no need for params, we delete_resp_cookie passing the name of the cookie (ruid)
    |> put_status(200)
    # Then we put the status of 200 which means it's successful but we did not create anything
    |> text("Log out successful.")
    # And finally we will pass out a message above
  end
end
