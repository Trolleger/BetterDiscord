import Config

config :chat_app, ChatApp.Repo,
  username: "root",
  password: "G7ADSg4SG&ADSKIEBIDITOILETTTAIDSSSSADS",
  hostname: "cockroachdb",
  port: 26257,
  database: "chat_app",
  ssl: [
    cacertfile: "/certs/ca.crt",
    certfile: "/certs/client.root.crt",
    keyfile: "/certs/client.root.key",
    verify: :verify_peer,
    server_name_indication: :disable  # Changed from "cockroachdb" to :disable
  ],
  pool_size: 10,
  show_sensitive_data_on_connection_error: true,
  stacktrace: true,
  parameters: [application_name: "chat_app"],
  migration_lock: nil,
  migration_primary_key: [type: :uuid],
  migration_foreign_key: [type: :uuid],
  migration_timestamps: [type: :timestamptz, inserted_at: :created_at],
  protocol: :postgres

config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "default_dummy_key",
  watchers: []

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

config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20
config :chat_app, dev_routes: true
config :swoosh, :api_client, false
