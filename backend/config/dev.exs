import Config

config :chat_app, ChatApp.Repo,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: System.get_env("POSTGRES_DB") || "chat_app_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  migration_lock: false

# UNDER NO CIRCUMSTANCES REMOVE migration_lock: false UNDER NO. FUCKING. CIRCUMSTANCES

config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") ||
      "dev_secret_key_base_at_least_64_characters_long_for_development",
  watchers: []

config :logger, level: :debug

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :chat_app, ChatApp.Guardian,
  secret_key:
    System.get_env("GUARDIAN_SECRET") ||
      "dev_guardian_secret_at_least_64_characters_long_for_development"
