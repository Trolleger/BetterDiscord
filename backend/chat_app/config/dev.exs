import Config

# Check if certificates exist before trying to use SSL
cert_base_path = Path.expand("../../certs", __DIR__)
ca_cert_path = Path.join(cert_base_path, "ca.crt")
client_cert_path = Path.join(cert_base_path, "client.root.crt")
client_key_path = Path.join(cert_base_path, "client.root.key")

# Only use SSL if all certificate files exist
ssl_config = if File.exists?(ca_cert_path) and File.exists?(client_cert_path) and File.exists?(client_key_path) do
  [
    cacertfile: ca_cert_path,
    certfile: client_cert_path,
    keyfile: client_key_path,
    verify: :verify_peer
  ]
else
  false
end

# Database Configuration (CockroachDB with conditional SSL)
config :chat_app, ChatApp.Repo,
  username: "root",
  password: "",
  hostname: "localhost",
  port: 26257,
  database: "chat_app_dev",
  pool_size: 10,
  ssl: ssl_config,
  migration_lock: nil,
  migration_primary_key: [type: :uuid],
  migration_foreign_key: [type: :uuid],
  migration_timestamps: [
    type: :timestamptz,
    inserted_at: :created_at
  ],
  protocol: :postgres,
  parameters: [application_name: "chat_app_dev"],
  show_sensitive_data_on_connection_error: true,
  stacktrace: true

# Endpoint Configuration - API only, no watchers
config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  secret_key_base: "T4C7UbFwRlBzizEK2abrkU8kcCE2oKhgdCAvc8Gmhv5L/Dkxor1Irxd9Kn7cX0fz",
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# CORS Configuration
config :cors_plug,
  origin: ["http://localhost:3000", "http://localhost", "http://localhost:80", "http://127.0.0.1:3000", "http://127.0.0.1", "http://127.0.0.1:80"],
  credentials: true,
  headers: ["content-type", "authorization", "x-requested-with"],
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]

# Logger
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

# Phoenix
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

# Environment flags
config :chat_app, dev_routes: true
config :swoosh, :api_client, false
