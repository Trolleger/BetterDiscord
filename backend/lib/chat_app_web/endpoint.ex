defmodule ChatAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat_app

  plug(Plug.Static,
    at: "/",
    from: :chat_app,
    gzip: false,
    only: ~w(favicon.ico robots.txt)
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # Put CORSPlug here before session and router
  plug(CORSPlug,
    origin: String.split(System.get_env("CORS_ORIGINS") || "http://localhost:3000", ","),
    headers: ["Authorization", "Content-Type", "Accept", "x-skip-auth-refresh"],
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_credentials: true,
    send_preflight_response?: true
  )

  plug(Plug.Session,
    store: :cookie,
    key: "_chat_app_key",
    signing_salt: System.get_env("SESSION_SIGNING_SALT"),
    secure: Mix.env() == :prod,
    http_only: true,
    same_site: "Lax"
  )

  plug(ChatAppWeb.Plugs.CSPPlug)
  plug(ChatAppWeb.Router)
end
