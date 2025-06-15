import Config

# Dynamic cert path resolution
cert_base_path = Path.expand("../../certs", __DIR__)
ca_cert_path = Path.join(cert_base_path, "ca.crt")
client_cert_path = Path.join(cert_base_path, "client.root.crt")
client_key_path = Path.join(cert_base_path, "client.root.key")

ssl_config = [
  cacertfile: ca_cert_path,
  certfile: client_cert_path,
  keyfile: client_key_path,
  verify: :verify_peer
]

# CockroachDB configuration
config :chat_app, ChatApp.Repo,
  username: "root",
  password: "",
  hostname: "cockroachdb",
  port: 26257,
  database: "chat_app_dev",
  ssl: ssl_config,
  pool_size: 10,
  show_sensitive_data_on_connection_error: true,
  stacktrace: true,
  parameters: [application_name: "chat_app_dev"],
  migration_lock: nil,
  migration_primary_key: [type: :uuid],
  migration_foreign_key: [type: :uuid],
  migration_timestamps: [type: :timestamptz, inserted_at: :created_at],
  protocol: :postgres

# Endpoint with reload and debug enabled
config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "default_dummy_key",
  watchers: []

# CORS - for localhost React frontend
config :cors_plug,
  origin: [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost",
    "http://127.0.0.1"
  ],
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  headers: ["authorization", "content-type", "x-requested-with"],
  credentials: true

# Logging config
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

# Dev mode flags
config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20
config :chat_app, dev_routes: true
config :swoosh, :api_client, false
