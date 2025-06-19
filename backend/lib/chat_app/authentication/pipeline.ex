defmodule ChatApp.Guardian.AuthPipeline do
  # We will now create the auth pipeline which we are going to use inside of our router to make sure that it pipes through this entire thing and makes sure
  # everything is setup in terms of authentication
  # So inside of here we will do a couple of things.

  # We want to define the claims which are going to be of type access which means that each time this goes through this pipeline it has to be a token which is of type access
  # So we will create 2 different types of tokens, the refresh token and the access token which is basically going to create the entire authentication system and because of this on this
  # Auth pipeline we do not want to have refresh tokens that is going to be handeled within the router and not here
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
  otp_app: :chat_app,
  # Its pulling the settings from THE MIX.EXS it has to match you know so it can't be chatapp, look at the mix.exs bro
  module: ChatApp.Guardian,
  error_handler: ChatApp.Guardian.AuthErrorHandler
  # So we add within this file that we are going to use the ChatApp.Guardian.AuthPipeline inside of this module and then we set the otp_app as our application
  # then we add the module which is ChatApp.Guardian (which we will create)
  # Then we add the error_handler: ChatApp.Guardian.AuthErrorHandler as the error handler
  plug(Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer")
  # So we add these 3 different plugs. 1. That verifies the header with the claims and in the realm of bearer (we have to pass to the header a authorization that has bearer then a space then the json token)
  plug(Guardian.Plug.EnsureAuthenticated)
  # Then we make sure this is authenticated
  plug(Guardian.Plug.LoadResource, ensure: true)
  # And we make sure the resource (like the user) gets loaded from the token and is available in our controller later, always present and all
end
