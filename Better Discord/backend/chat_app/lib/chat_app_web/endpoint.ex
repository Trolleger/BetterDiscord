defmodule ChatAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat_app

  @session_options [
    store: :cookie,
    key: "_chat_app_key",
    signing_salt: "e+ArmAbm",
    same_site: "Lax"
  ]

  plug Plug.Static,
    at: "/",
    from: :chat_app,
    gzip: false,
    only: ChatAppWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :chat_app
  end

  plug CORSPlug,
    origin: ["http://localhost", "http://localhost:80", "http://localhost:3000"],
    credentials: true

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ChatAppWeb.Router
end