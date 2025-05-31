import Config

# Auto-generate development secret key (safe for local use)
secret_key_base = System.get_env("SECRET_KEY_BASE") ||
  "dev_" <> (:crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64))

# Determine if we're running in Docker or locally
in_docker = System.get_env("DATABASE_URL") != nil
hostname = if in_docker, do: "cockroachdb", else: "localhost"

# Certificate paths - different for Docker vs local
cert_base_path = if in_docker do
  "/app/priv/certs"
else
  Path.expand("../../certs", __DIR__)
end

# Database Configuration (CockroachDB with SSL)
config :chat_app, ChatApp.Repo,
  username: "root",
  password: "",
  hostname: hostname,
  port: 26257,
  database: "chat_app_dev",
  pool_size: 10,
  ssl: [
    cacertfile: Path.join(cert_base_path, "ca.crt"),
    certfile: Path.join(cert_base_path, "client.root.crt"),
    keyfile: Path.join(cert_base_path, "client.root.key"),
    verify: :verify_peer
  ],
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

# Endpoint Configuration
config :chat_app, ChatAppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  secret_key_base: secret_key_base,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:chat_app, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:chat_app, ~w(--watch)]}
  ],
  session: [
    store: :cookie,
    key: "_chat_app_key",
    signing_salt: "signing_salt_here"
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/chat_app_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

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
config :phoenix_live_view, :debug_heex_annotations, true

# Environment flags
config :chat_app, dev_routes: true
config :swoosh, :api_client, false
