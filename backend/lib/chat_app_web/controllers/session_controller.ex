defmodule ChatAppWeb.SessionController do
  # just like with view we want to add the look below
  use ChatAppWeb, :controller
  # And now we have to alias a couple of things
  alias ChatApp.Accounts
  alias ChatApp.Guardian
  # Alias both of these modules
  action_fallback ChatAppWeb.FallbackController
  # If something inside of this controller, and it matches anything in the fallback_controller.ex this is going to automatically give us back the error, instead of just the App Failing

  # Now we create 3 different functions. The New, The Refresh (Make sure somebody is authenticated and if they are refresh the session), The Delete
  # (Just goes ahead and deletes the cookies from the response and in the client we can handle that and make somebody log out of the application)
  def new(conn, %{"email" => email, "password" => password}) do
    # create a function for the controller, pass the connection, the email and the password which are going to be the values of the JSON sent from the client or from a rest client
    # And then we want to add here the following function which we created in accounts.ex (authenticate_user) which validates the password and makes sure it matches in the database and all
      case Accounts.authenticate_user(email, password) do
        {:ok, user} ->
          {:ok, access_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttll: {15, :minute})
          # So if all of this goes well we encode and sign the token, we grab the user and encode it wtih a token type access, and add a life time of 15 minutes to this token
          # Acess token -> 15 minutes -> refresh token (7 days or whatever) -> Each time that somebody sends us the request we're going to use the refresh token to get the access
          # token -> access token gets us the resources that we need -> never going to use just one token for the entire process, would be very unsafe and all

          # Now we also create the refresh token
          {:ok, refresh_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttll: {7, :day})
          # As you can see we do the same thing but changed token time and 7 day and we call the variable something different so no confliction

          conn
          |>put_resp_cookie("ruid", refresh_token)
          # and finally we're going to use the connection, put the resp_cookie (add the cookie to the response) with the following name: ruid and pass the refresh token, the R means refresh
          # So you know in this code what it really means
          |>put_status(:created)
          # Then you put a status of one in created
          |>render("token.json", access_token)
          # and finally render based on the view we just created in session_view.ex and basically we pass the exact same string and then we pass the access token to make sure it gives
          # use back the JSON token in the response and finally incase ALL OF THIS goes wrong we need to account for that so:

        {:error, :unauthorized} ->
          body = Jason.encode!(%{error: "unauthorized"})

          conn
          |> send_resp(401, body)
          # So incase we get an error we incode the JSON here and just put unauthorized because we do not want to disclose a lot of information about what's happening in the auth process
          # then we set ar esponse with a 401 and the following body,
          # So with then new session_function created we need to add the refresh function
      end
  end
  def refresh(conn, _params) do
    # we pass again the connection, and we do not need the params since we will fetch them from the cookeis
    refresh_token = Plug.Conn.fetch_cookies(conn) |> Map.from_struct |> get_in({:cookies, "ruid"})
    # In this code we fetch the cookies from the connnection, create a map from the struct and then get the following item from the cookies

    case Guardian.exchange(refresh_token, "refresh", "access") do
      # So we use guardian and use something they gave us called exchange, what it does is, we pass the refresh token inside exchange and we tell guardian to
      # exactly what we want to exchange, we want to exchange refresh token for an access token, as the guy in the tutorial says "this is why I believe phoenix
      # is very useful for programmers when developing applications, instead of doing something like rails and giving us everything and then we don't really know what's happening,
      # Or building something from scratch and creating all this logic ourselves phoenix gives us these libraries that really help us with these utilites, so this is basically going
      # to receive our refresh token and then we say we want to exchange the refresh for the access and then here we get back the new access token and then we basically return the connection
      # we just create a status and then we render again the token.json
      {:ok, _old_stuff, %{new_access_token: new_access_token, _new_claims: _new_claims}} ->
        conn
        |>put_status(:created)
        |>render("token.json", %{access_token: new_access_token})
        # In case something goes wrong we have below: (Or the following if you want to say it that way)
      {:error, _reason} ->
        body = Jason.encode!(%{error: "unauthorized"})
        conn
        |>send_resp(401, body)
        # Incase an error arises we just pass here the body (jason.encode) and unauthorized message and return it with a 401 code

    end
  end
  # FINALLY we have to add the delete function that is going to help us log out our user and this is not going to be used by itself we need some strategy on your frontend to ensure
  # that you clear EVERYTHING, this just clears the cookies which is the system which the guy does which is store in memory the access cookie and just add to the cookie the refresh token
  # if you clear the cookie and refresh the page it will automatically log out this is why this is simple and also very effective with that in mind let us create the function
  # TODO: Implement logout by clearing refresh token cookie and making sure frontend clears auth state
  # TODO: Actually fucking implement the frontend logging in and shit
  # TODO: yeah quite a few todo's also make sure stuff works with OAUTH, get TODO tree, very effective

  def delete(conn, _params) do
    conn
    |> delete_resp_cookie("ruid")
    # as you can see this is very simple, we pass the conn, no need for params we use the cookies and them we simply delete_resp_cookie pass the name of the cookie (which is the refresh unique id)
    |> put_status(200)
    # Then we put the status of 200 which means it's succsessful but we did not create anything
    |> text("Log out successful.")
    # And finally we will pass out a message above
  end
end
