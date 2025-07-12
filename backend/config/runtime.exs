import Config

# Runtime configuration (uses environment variables)
if System.get_env("PHX_SERVER") do
  config :chat_app, ChatAppWeb.Endpoint, server: true
end

# Repo config (PostgreSQL, no TLS for now)
config :chat_app, ChatApp.Repo,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  migration_primary_key: [type: :uuid],
  migration_foreign_key: [type: :uuid],
  migration_timestamps: [type: :timestamptz, inserted_at: :created_at]

# Endpoint config for all envs: session options set here to avoid nil crash
session_signing_salt =
  System.get_env("SESSION_SIGNING_SALT") ||
    raise "SESSION_SIGNING_SALT environment variable is missing. Set it in your .env"

session_opts = [
  store: :cookie,
  key: "_chat_app_key",
  signing_salt: session_signing_salt,
  secure: config_env() == :prod,
  http_only: true,
  same_site: "Lax"
]

config :chat_app, ChatAppWeb.Endpoint,
  http: [
    ip: {0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  server: true,
  session_options: session_opts

# Google OAuth2
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_CLIENT_REDIRECT")

# Guardian JWT
config :chat_app, ChatApp.Guardian,
  issuer: "chat_app",
  ttl: {15, :minutes},
  secret_key: System.fetch_env!("GUARDIAN_SECRET"),
  allowed_algos: ["HS256"],
  verify_issuer: true

# CORS Origins - Fixed to handle nil case
cors_origins = System.get_env("CORS_ORIGINS") || "http://localhost:3000"

config :cors_plug,
  origin: String.split(cors_origins, ","),
  headers: ["Authorization", "Content-Type", "Accept"],
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  credentials: true
