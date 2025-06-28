defmodule ChatAppWeb.Router do
  @moduledoc """
  Defines app routes:
  - OAuth handled by Ueberauth plug.
  - Public API routes accept JSON.
  - Protected API routes require JWT auth via Guardian pipeline.
  """
  use ChatAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :oauth do
    plug Ueberauth
  end

  pipeline :auth do
    plug ChatApp.Guardian.AuthPipeline
  end

  scope "/", ChatAppWeb do
    pipe_through :api
    get "/", HealthcheckController, :index
  end

  scope "/api", ChatAppWeb do
    pipe_through :api
    get "/health_check", HealthcheckController, :index

    post "/register", Auth.SessionController, :register
    post "/login", Auth.SessionController, :login
    post "/refresh", Auth.SessionController, :refresh
    delete "/logout", Auth.SessionController, :logout
  end

  scope "/", ChatAppWeb do
    pipe_through [:api, :oauth]
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
  end

  scope "/api", ChatAppWeb do
    pipe_through [:api, :auth]
    get "/profile", AuthController, :profile
    post "/complete-profile", AuthController, :complete_profile
  end
end
