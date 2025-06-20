import Config

# General application configuration
config :chat_app,
  ecto_repos: [ChatApp.Repo],
  generators: [timestamp_type: :utc_datetime]

# Endpoint configuration (non-sensitive)
config :chat_app, ChatAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ChatAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ChatApp.PubSub

# Logger configuration
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# JSON library
config :phoenix, :json_library, Jason

# Ueberauth providers setup (without secrets)
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

# Guardian JWT configuration (non-secret parts)
config :chat_app, ChatApp.Guardian,
  issuer: "chat_app"

# Import environment-specific config (dev.exs, prod.exs, etc.)
import_config "#{config_env()}.exs"
