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

  plug(Plug.Session,
    store: :cookie,
    key: "_chat_app_key",
    signing_salt: "CHANGE_ME"
  )

  # Use env directly — no backup, no games
  plug(CORSPlug,
    origin: String.split(System.get_env("CORS_ORIGINS") || "", ","),
    headers: ["Authorization", "Content-Type", "Accept"],
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_credentials: true,
    send_preflight_response?: true
    # *So no 204 header errors ^
  )

  plug(ChatAppWeb.Router)
end
