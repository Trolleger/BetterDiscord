defmodule ChatApp.MediasoupClient do
  use WebSockex

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %{}, name: __MODULE__)
  end

  def send_message(msg) do
    WebSockex.send_frame(__MODULE__, {:text, Jason.encode!(msg)})
  end

  def handle_frame({:text, msg}, state) do
    decoded = Jason.decode!(msg)
    ChatAppWeb.Endpoint.broadcast!("mediasoup:lobby", "mediasoup_event", decoded)
    {:ok, state}
  end

  def handle_disconnect(reason, state) do
    IO.puts("Disconnected from mediasoup Node: #{inspect(reason)}")
    {:reconnect, state}
  end
end
