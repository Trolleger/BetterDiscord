import Config

# Auto-generate development secret key (safe for local use)
secret_key_base = System.get_env("SECRET_KEY_BASE") || 
  "dev_" <> (:crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64))

# Database Configuration (CockroachDB optimized)
config :chat_app, ChatApp.Repo,
  username: "root",
  password: "",
  hostname: "cockroachdb",
  port: 26257,
  database: "chat_app_dev",
  pool_size: 10,
  ssl: false,
  # CockroachDB-specific settings
  migration_lock: nil,                    # Disables unsupported LOCK TABLE
  migration_primary_key: [type: :uuid],   # Best for distributed DBs
  migration_foreign_key: [type: :uuid],   # Consistent references
  migration_timestamps: [
    type: :timestamptz,
    inserted_at: :created_at              # CockroachDB convention
  ],
  protocol: :postgres,
  parameters: [application_name: "chat_app_dev"],
  # Debug settings
  show_sensitive_data_on_connection_error: true,
  stacktrace: true

# Endpoint Configuration
config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  secret_key_base: secret_key_base,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Logger
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

# Phoenix
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

# Environment flags
config :chat_app, dev_routes: false
config :swoosh, :api_client, false