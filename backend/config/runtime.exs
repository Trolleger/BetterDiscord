import Config

# Runtime configuration (uses environment variables)
if System.get_env("PHX_SERVER") do
  config :chat_app, ChatAppWeb.Endpoint, server: true
end

# Repo config (CockroachDB + TLS)
config :chat_app, ChatApp.Repo,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: [
    cacertfile: System.get_env("SSLROOTCERT") || "/certs/ca.crt",
    certfile: System.get_env("SSLCERT") || "/certs/client.root.crt",
    keyfile: System.get_env("SSLKEY") || "/certs/client.root.key",
    verify: :verify_peer,
    server_name_indication:
      case System.get_env("DB_HOST") do
        nil -> if config_env() == :dev, do: :disable, else: "cockroachdb"
        host -> host
      end
  ],
  migration_primary_key: [type: :uuid],
  migration_foreign_key: [type: :uuid],
  migration_timestamps: [type: :timestamptz, inserted_at: :created_at]

# Endpoint config for production/runtime
if config_env() != :dev do
  config :chat_app, ChatAppWeb.Endpoint,
    http: [
      ip: {0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    server: true
end

# Google OAuth2
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")

# Guardian JWT
config :chat_app, ChatApp.Guardian,
  issuer: "chat_app",
  ttl: {15, :minutes},
  secret_key: System.fetch_env!("GUARDIAN_SECRET"),
  allowed_algos: ["HS256"],
  verify_issuer: true

# Session signing salt
config :chat_app, ChatAppWeb.Endpoint,
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  signing_salt: System.fetch_env!("SESSION_SIGNING_SALT")

# CORS Origins - Fixed to handle nil case
cors_origins = System.get_env("CORS_ORIGINS") || "http://localhost:3000"

config :cors_plug,
  origin: String.split(cors_origins, ","),
  headers: ["Authorization", "Content-Type", "Accept"],
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  credentials: true
