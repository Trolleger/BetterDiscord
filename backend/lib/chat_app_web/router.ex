defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

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

  pipeline :auth do
    plug(Ueberauth)
  end

  # Health check
  scope "/", ChatAppWeb do
    pipe_through(:api)
    get("/", StatusController, :status)
  end

  # OAuth (Google etc.)
  scope "/", ChatAppWeb do
    pipe_through([:api, :auth])
    get("/auth/:provider", AuthController, :request)
    get("/auth/:provider/callback", AuthController, :callback)
  end

  # Manual Signup stuff
  scope "/api", ChatAppWeb do
    # Use the :api pipeline, which handles JSON requests and CORS
    pipe_through(:api)

    # Custom route for user registration (e.g., manual signup)
    post("/users", UserController, :register)
    # What happens is that each time someone requests, first of all then the localhost, then the port, then the /api/users and then
    # this calls within the usercontroller the register function and basically create a user
    # and if we go in the rest client we will see this is working

    # Health check endpoint to get status info
    get("/status", StatusController, :status)

  end
end
