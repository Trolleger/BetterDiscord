defmodule ChatAppWeb.RoomChannel do
  use Phoenix.Channel

  # Allow anyone to join the public "room:lobby"
  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  # Any topic other than "room:lobby" is considered private.
  # We'll require special authorization later (e.g., database check).
  # For now, we just reject all other room joins. Change this later OBV!
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  # Handle incoming events
  # This will listen for "new_msg" pushes from the client.
  # It takes 3 params:
  #   - event name: "new_msg"
  #   - payload: the data sent by the client (e.g., %{"body" => "hi"})
  #   - socket: holds topic/assigns and lets us reply or broadcast
  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast_from!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end

# TODO: In the future, if we want to filter outgoing events per user,
# like ignoring some users' messages or presence events, we can use:
#
#   intercept ["event_name"]
#
#   def handle_out("event_name", msg, socket) do
#     # Conditionally push or skip based on socket assigns
#     {:noreply, socket}
#   end
# Etc, Etc you got the idea
