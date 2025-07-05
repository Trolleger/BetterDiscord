defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ChatAppWeb.Plugs.SimpleRateLimiter   # Add it here so all API requests get rate limited (you can restrict in the plug itself)
  end

  # Full auth pipeline, requires valid access token
  pipeline :auth do
    plug ChatApp.Guardian.AuthPipeline
  end

  # Optional auth pipeline, does NOT require valid token (for refresh endpoint)
  pipeline :optional_auth do
    plug ChatApp.Guardian.AuthPipeline.Optional
  end

  scope "/api", ChatAppWeb do
    pipe_through :api

    get "/health_check", HealthcheckController, :index
    post "/register", Auth.SessionController, :register
    post "/login", Auth.SessionController, :login
    delete "/logout", Auth.SessionController, :logout  # No auth needed to clear cookie
  end

  scope "/api", ChatAppWeb do
    pipe_through [:api, :optional_auth]

    post "/refresh", Auth.SessionController, :refresh
  end

  scope "/api", ChatAppWeb do
    pipe_through [:api, :auth]

    get "/profile", AuthController, :profile
    get "/socket-token", Auth.TokenController, :socket
  end
end
