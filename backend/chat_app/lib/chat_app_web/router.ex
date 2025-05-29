defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Ueberauth
  end

  # Health check/status endpoint
  scope "/", ChatAppWeb do
    pipe_through :api
    get "/", StatusController, :status
  end

  # API Routes
  scope "/api", ChatAppWeb do
    pipe_through :api
    get "/status", StatusController, :status
    # Add other API endpoints here
  end

  # OAuth Routes
  scope "/api/auth", ChatAppWeb do
    pipe_through [:api, :auth]
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
end
