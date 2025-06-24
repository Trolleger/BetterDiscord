import Config

# Debug settings
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20

# Enable dev-only features
config :chat_app, dev_routes: true
config :swoosh, :api_client, false

config :chat_app, ChatApp.Repo,
  migration_lock: false
