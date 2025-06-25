defmodule ChatAppWeb.Router do
  @moduledoc """
  Defines app routes:

  - OAuth routes handled by Ueberauth plug.
  - Public API routes accepting JSON.
  - Protected API routes requiring JWT authentication via Guardian pipeline.
  """

  use ChatAppWeb, :router

  # Accept JSON requests
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Pipeline for OAuth routes (adds Ueberauth plug)
  pipeline :oauth do
    plug Ueberauth
  end

  # Pipeline to enforce Guardian authentication on protected routes
  pipeline :auth do
    plug ChatApp.Guardian.AuthPipeline
  end

  # Public status route
  scope "/", ChatAppWeb do
    pipe_through :api
    get "/", StatusController, :status
  end

  # OAuth login and callback routes
  scope "/", ChatAppWeb do
    pipe_through [:api, :oauth]
    get "/auth/:provider", AuthController, :request    # Redirect to OAuth provider
    get "/auth/:provider/callback", AuthController, :callback  # OAuth callback handling
  end

  # Public API routes - registration, manual login, token refresh, logout
  scope "/api", ChatAppWeb do
    pipe_through :api
    post "/register", Auth.SessionController, :register   # Add this line for registration
    post "/login", Auth.SessionController, :new           # Manual login (email/password)
    post "/refresh", Auth.SessionController, :refresh     # Refresh access token with refresh token cookie
    delete "/logout", Auth.SessionController, :delete     # Logout clears refresh token cookie
  end

  # Protected API routes that require valid access token
  scope "/api", ChatAppWeb do
    pipe_through [:api, :auth]

    get "/profile", AuthController, :user                 # Get current user info
    post "/complete-profile", AuthController, :complete_profile  # Complete profile (e.g. username) after OAuth login
  end
end
