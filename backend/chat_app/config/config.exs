# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chat_app,
  ecto_repos: [ChatApp.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :chat_app, ChatAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ChatAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ChatApp.PubSub

# Configures the mailer
config :chat_app, ChatApp.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# === Ueberauth Google OAuth config ===
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID") || "58516048770-lqsao96iscal7fb850pgmre3cmhpvm6q.apps.googleusercontent.com",
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET") || "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",
  redirect_uri: "http://localhost:4000/auth/google/callback"

# === End Ueberauth config ===

# Import environment specific config
import_config "#{config_env()}.exs"
