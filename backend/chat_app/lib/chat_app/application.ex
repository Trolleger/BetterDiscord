defmodule ChatApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # NOTE: This mediasoup call will fail because there is NO Elixir mediasoup binding.
    # You must run mediasoup server separately in Node.js (as discussed).
    # Remove mediasoup logic here or use a client WebSocket connection to Node mediasoup server instead.

    children = [
      ChatAppWeb.Telemetry,
      ChatApp.Repo,
      {DNSCluster, query: Application.get_env(:chat_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChatApp.PubSub},
      {Finch, name: ChatApp.Finch},
      ChatAppWeb.Endpoint,
      # Start the mediasoup client WebSocket connector
      {ChatApp.MediasoupClient, "ws://mediasoup-server:3000"}
    ]

    opts = [strategy: :one_for_one, name: ChatApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChatAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
