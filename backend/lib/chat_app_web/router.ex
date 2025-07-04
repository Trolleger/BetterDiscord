# lib/chat_app_web/router.ex
defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ChatApp.Guardian.AuthPipeline
  end

  scope "/api", ChatAppWeb do
    pipe_through :api

    get "/health_check", HealthcheckController, :index
    post "/register", Auth.SessionController, :register   # if you have a register action
    post "/login", Auth.SessionController, :login
    post "/refresh", Auth.SessionController, :refresh
    delete "/logout", Auth.SessionController, :logout
  end

  scope "/api", ChatAppWeb do
    pipe_through [:api, :auth]
    get "/profile", AuthController, :profile
    get "/socket-token", Auth.TokenController, :socket
  end
end
