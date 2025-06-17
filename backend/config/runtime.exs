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
    ]

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
