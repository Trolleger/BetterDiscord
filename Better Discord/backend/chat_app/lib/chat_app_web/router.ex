# lib/chat_app_web/router.ex
defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  # -- API pipeline, for JSON endpoints --
  pipeline :api do
    plug :accepts, ["json"]
  end

  # -- Serve GET "/" as JSON via your StatusController --
  scope "/", ChatAppWeb do
    pipe_through :api

    get "/", StatusController, :status
  end

  # -- API routes under /api --
  scope "/api", ChatAppWeb do
    pipe_through :api

    get "/status", StatusController, :status
    # …other JSON endpoints…
  end
end
