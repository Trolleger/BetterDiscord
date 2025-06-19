import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: "postgresql://root@cockroachdb:26257/chat_app?sslmode=verify-full&sslcert=/certs/client.root.crt&sslkey=/certs/client.root.key&sslrootcert=/certs/ca.crt"
      """

  config :chat_app, ChatApp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: [
      cacertfile: System.get_env("SSLROOTCERT") || "/certs/ca.crt",
      certfile: System.get_env("SSLCERT") || "/certs/client.root.crt",
      keyfile: System.get_env("SSLKEY") || "/certs/client.root.key",
      verify: :verify_peer,
      server_name_indication: "cockroachdb"
    ],
    migration_lock: nil,
    migration_primary_key: [type: :uuid],          # UUID primary key type
    migration_foreign_key: [type: :uuid],          # UUID foreign keys
    migration_timestamps: [type: :timestamptz, inserted_at: :created_at]  # Timestamps aligned with CockroachDB

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "environment variable SECRET_KEY_BASE is missing."

  config :chat_app, ChatAppWeb.Endpoint,
    http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
    secret_key_base: secret_key_base,
    server: true,
    url: [host: System.get_env("PHX_HOST") || "example.com", port: 80],
    cache_static_manifest: "priv/static/cache_manifest.json"
end

if config_env() == :dev do
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
      server_name_indication: :disable    # For dev, disable SNI to avoid issues
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
end

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
