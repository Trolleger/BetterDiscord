import Config

config :chat_app, ChatAppWeb.Endpoint,
  http: [
    ip: {0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  url: [host: System.get_env("HOST") || "example.com", port: 443, scheme: "https"],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  force_ssl: [hsts: true],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  # Make sure session cookies are secure in prod (your endpoint.ex already sets this)
  # Also double check your CORS config allows your real frontend domain in prod
  check_origin: [System.get_env("FRONTEND_URL") || "https://yourdomain.com"]

config :logger, level: :info
