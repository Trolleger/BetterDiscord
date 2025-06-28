defmodule ChatAppWeb.Plugs.CSPPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header(
      "content-security-policy",
      "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; object-src 'none'"
    )
  end
end
