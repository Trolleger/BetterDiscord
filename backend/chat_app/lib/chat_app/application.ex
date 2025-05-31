defmodule ChatApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Start Mediasoup worker and router here:
    {:ok, worker} = :mediasoup.createWorker()

    media_codecs = [
      %{
        kind: "audio",
        mimeType: "audio/opus",
        clockRate: 48000,
        channels: 2
      },
      %{
        kind: "video",
        mimeType: "video/VP8",
        clockRate: 90000,
        parameters: %{}
      }
    ]

    {:ok, router} = :mediasoup_worker.createRouter(worker, %{mediaCodecs: media_codecs})

    # Store router PID globally for access in channels:
    :persistent_term.put(:mediasoup_router, router)

    children = [
      ChatAppWeb.Telemetry,
      ChatApp.Repo,
      {DNSCluster, query: Application.get_env(:chat_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChatApp.PubSub},
      {Finch, name: ChatApp.Finch},
      ChatAppWeb.Endpoint
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
