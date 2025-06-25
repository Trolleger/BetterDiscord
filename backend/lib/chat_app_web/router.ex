defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  # Pipeline for JSON API requests
  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Pipeline to plug Ueberauth (OAuth)
  pipeline :oauth do
    plug(Ueberauth)
  end

  # Pipeline for JWT authentication (Guardian)
  pipeline :auth do
    plug(ChatApp.Guardian.AuthPipeline)
  end

  # Public root health check
  scope "/", ChatAppWeb do
    pipe_through(:api)
    get("/", StatusController, :status)
  end

  # OAuth routes: request + callback
  scope "/", ChatAppWeb do
    pipe_through([:api, :oauth])
    get("/auth/:provider", AuthController, :request)
    get("/auth/:provider/callback", AuthController, :callback)
  end

  # Public API routes (no auth needed)
  scope "/api", ChatAppWeb do
    pipe_through(:api)

    post("/users", Users.UserController, :register)
    post("/session/new", Auth.SessionController, :new)

    get("/status", StatusController, :status)
    get("/healthcheck", HealthcheckController, :index)

    # Profile completion endpoint (needs temp token from cookie)
    post("/complete-profile", AuthController, :complete_profile)
  end

  # Protected API routes (require valid JWT)
  scope "/api", ChatAppWeb do
    pipe_through([:api, :auth])

    post("/session/refresh", Auth.SessionController, :refresh)
    post("/session/delete", Auth.SessionController, :delete)
    get("/profile", Users.ProfileController, :show)
  end
end
