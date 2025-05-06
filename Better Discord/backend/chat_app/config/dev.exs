import Config

# Configure your database (CockroachDB)
config :chat_app, ChatApp.Repo,
  username: "root",
  password: "",
  hostname: "localhost",  # Changed from "cockroachdb" to "localhost"
  port: 26257,
  database: "chat_app_dev",
  ssl: false,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Endpoint configuration
config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "912UM4qH56DR+puJxrnU+zcbIHIhq0UxR81puy9McK/tuxFhgniIbTmbeYlCwbzR"  # Removed the extra comma here

# Disable dev_routes like dashboard & mailbox
config :chat_app, dev_routes: false

# Logger formatting
config :logger, :console,
  format: "[$level] $message\n"

# Development settings
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client in development
config :swoosh, :api_client, false
