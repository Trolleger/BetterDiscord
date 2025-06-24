defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  # General API pipeline: accepts JSON, handles CORS
  pipeline :api do
    plug(:accepts, ["json"])

    plug(CORSPlug,
      origin: [
        "http://localhost",
        "http://localhost:80",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1"
      ]
    )
  end

  # OAuth pipeline (for Google login etc.)
  pipeline :oauth do
    plug(Ueberauth)
  end

  # Guardian JWT auth pipeline for protected routes
  pipeline :auth do
    plug(ChatApp.Guardian.AuthPipeline)
    # This custom pipeline runs all plugs defined in AuthPipeline (like verifying JWT tokens).
    # We’ll use it for routes that require authentication.
  end

  # Health check route, root-level — used to check if the server is alive
  scope "/", ChatAppWeb do
    pipe_through(:api)
    get("/", StatusController, :status)
  end

  # OAuth (Google or other providers) routes
  scope "/", ChatAppWeb do
    pipe_through([:api, :oauth])
    get("/auth/:provider", AuthController, :request)
    get("/auth/:provider/callback", AuthController, :callback)
  end

  # Public API routes — user registration and login
  scope "/api", ChatAppWeb do
    pipe_through(:api)
    # These routes are public and do NOT require authentication.
    # Only go through the basic :api pipeline (CORS + JSON parsing).

    post("/users", Users.UserController, :register)
    # POST /api/users → handles manual user registration.

    post("/session/new", Auth.SessionController, :new)
    # POST /api/session/new → handles login and returns access/refresh token.

    get("/status", StatusController, :status)
    # GET /api/status → a health check endpoint, returns basic server info.


  end

  # Protected API routes — require valid JWT access token
  scope "/api", ChatAppWeb do
    pipe_through([:api, :auth])
    # These routes require both the :api and :auth pipelines.
    # That means CORS + JSON + token verification via Guardian.

    post("/session/refresh", Auth.SessionController, :refresh)
    # POST /api/session/refresh → exchanges refresh token for a new access token.

    post("/session/delete", Auth.SessionController, :delete)
    # POST /api/session/delete → logs out user by clearing the cookie.
    # This uses POST (not DELETE) to match the tutorial — valid, just not RESTful.
    # You can later add a proper DELETE route too, but this works fine for now.

    get "/profile", Users.ProfileController, :show
    # Goes to the USER's JWT token and then get's the responding information
  end
end
