defmodule ChatAppWeb.MediasoupChannel do
  use Phoenix.Channel

  def join("mediasoup:lobby", _params, socket) do
    {:ok, socket}
  end

  def handle_in("signal", payload, socket) do
    ChatApp.MediasoupClient.send_message(payload)
    {:noreply, socket}
  end
end
