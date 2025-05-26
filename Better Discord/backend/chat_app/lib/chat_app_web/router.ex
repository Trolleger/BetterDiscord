defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  # -- API pipeline, for JSON endpoints --
  pipeline :api do
    plug :accepts, ["json"]
  end

  # -- OAuth pipeline --
  pipeline :auth do
    plug Ueberauth
  end

  # -- Root JSON endpoint --
  scope "/", ChatAppWeb do
    pipe_through :api

    get "/", StatusController, :status
  end

  # -- Main API JSON endpoints --
  scope "/api", ChatAppWeb do
    pipe_through :api

    get "/status", StatusController, :status
    # Add other JSON endpoints here
  end

  # -- OAuth endpoints --
  scope "/auth", ChatAppWeb do
    pipe_through [:api, :auth]

    get "/google", AuthController, :request
    get "/google/callback", AuthController, :callback
  end
end
