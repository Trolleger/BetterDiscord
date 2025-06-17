defmodule ChatAppWeb.UserController do
  use ChatAppWeb, :controller

  alias ChatApp.Accounts
  alias ChatApp.Accounts.User

  action_fallback ChatAppWeb.FallbackController
end
# DONT WORRY ABOUT MISSING ERRORS OR SHIT LIKE THIS OR THAT WE WILL BE FIXING IT LATER
