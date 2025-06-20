import Config

# Debug settings
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20

# Enable dev-only features
config :chat_app, dev_routes: true
config :swoosh, :api_client, false

# CORS for development
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
