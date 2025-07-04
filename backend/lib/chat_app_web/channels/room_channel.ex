defmodule ChatAppWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  # Any topic other than "room:lobby" is considered private.
  # We'll require special authorization later (e.g., database check).
  # For now, we just reject all other room joins. Change this later OBV!
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end
