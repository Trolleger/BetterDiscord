defmodule ChatAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat_app

  # Only include session if you're using cookies for auth
  plug Plug.Session,
    store: :cookie,
    key: "_chat_app_key",
    signing_salt: "e+ArmAbm" # Keep your existing salt

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  # Basic CORS (adjust origins as needed)
  plug CORSPlug, origin: ["http://localhost:3000"]

  plug Plug.RequestId
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug ChatAppWeb.Router
end
