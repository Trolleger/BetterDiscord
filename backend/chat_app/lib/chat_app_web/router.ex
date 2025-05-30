defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["http://localhost", "http://localhost:80"]
  end

  pipeline :auth do
    plug Ueberauth
  end

  # Health check/status endpoint
  scope "/", ChatAppWeb do
    pipe_through :api
    get "/", StatusController, :status
  end

  # OAuth Routes - match Google Console settings
  scope "/", ChatAppWeb do
    pipe_through [:api, :auth]
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
  end

  # API Routes
  scope "/api", ChatAppWeb do
    pipe_through :api
    get "/status", StatusController, :status
    # Add other API endpoints here
  end
end
