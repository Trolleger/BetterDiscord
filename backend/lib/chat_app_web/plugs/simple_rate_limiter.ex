defmodule ChatAppWeb.Plugs.SimpleRateLimiter do
  import Plug.Conn

  @limit 5
  @window_ms 60_000

  # We keep a map in process dictionary with {ip, timestamp} => count
  def init(opts), do: opts

  def call(conn, _opts) do
    ip = Tuple.to_list(conn.remote_ip) |> Enum.join(".")
    now = System.system_time(:millisecond)

    key = {ip, div(now, @window_ms)}

    count = get_count(key)
    if conn.request_path in ["/api/login", "/api/refresh"] and conn.method == "POST" and count >= @limit do
      conn
      |> send_resp(429, "Too many requests")
      |> halt()
    else
      increment_count(key)
      conn
    end
  end

  defp get_count(key) do
    Process.get(key, 0)
  end

  defp increment_count(key) do
    count = get_count(key) + 1
    Process.put(key, count)
  end
end
