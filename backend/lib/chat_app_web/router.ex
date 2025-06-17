defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: [
      "http://localhost",
      "http://localhost:80",
      "http://localhost:3000",
      "http://127.0.0.1:3000",
      "http://127.0.0.1"
    ]
  end

  pipeline :auth do
    plug Ueberauth
  end

  # Health check
  scope "/", ChatAppWeb do
    pipe_through :api
    get "/", StatusController, :status
  end

  # OAuth (Google etc.)
  scope "/", ChatAppWeb do
    pipe_through [:api, :auth]
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
  end

  # Main API
  scope "/api", ChatAppWeb do
    pipe_through :api
    get "/status", StatusController, :status

    # Here is the users resource with no new/edit routes (API only)
    resources "/users", UserController, except: [:new, :edit]
  end
end
