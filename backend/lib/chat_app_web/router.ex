defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  # Accept JSON requests
  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :oauth do
    plug(Ueberauth)
  end

  pipeline :auth do
    plug(ChatApp.Guardian.AuthPipeline)
  end

  # Root health check
  scope "/", ChatAppWeb do
    pipe_through(:api)
    get("/", StatusController, :status)
  end

  # OAuth routes (Google login)
  scope "/", ChatAppWeb do
    pipe_through([:api, :oauth])
    get("/auth/:provider", AuthController, :request)
    get("/auth/:provider/callback", AuthController, :callback)
  end

  # Public API routes (no auth)
  scope "/api", ChatAppWeb do
    pipe_through(:api)

    post("/users", Users.UserController, :register)

    post("/session/new", Auth.SessionController, :new)

    get("/status", StatusController, :status)
    get("/healthcheck", HealthcheckController, :index)
  end

  # Protected API routes (require JWT)
  scope "/api", ChatAppWeb do
    pipe_through([:api, :auth])

    post("/session/refresh", Auth.SessionController, :refresh)
    post("/session/delete", Auth.SessionController, :delete)
    get("/profile", Users.ProfileController, :show)
  end
end
