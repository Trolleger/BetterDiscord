defmodule ChatAppWeb.Plugs.CSPPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header(
      "content-security-policy",
      "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; object-src 'none'"
    )
    |> put_resp_header(
      "strict-transport-security",
      "max-age=31536000; includeSubDomains; preload"
    )
    |> put_resp_header("x-frame-options", "DENY")
    |> put_resp_header("x-content-type-options", "nosniff")
  end
end
