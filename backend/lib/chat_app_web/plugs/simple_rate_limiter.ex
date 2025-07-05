# defmodule ChatApp.Application do
#   use Application

#   @impl true
#   def start(_type, _args) do
#     children = [
#       ChatApp.Repo,
#       {DNSCluster, query: Application.get_env(:chat_app, :dns_cluster_query) || :ignore},
#       {Phoenix.PubSub, name: ChatApp.PubSub},
#       # Start the Finch HTTP client for sending emails
#       {Finch, name: ChatApp.Finch},
#       # Start the Endpoint (http/https)
#       ChatAppWeb.Endpoint,
#       # Start a worker by calling: ChatApp.Worker.start_link(arg)
#       # {ChatApp.Worker, arg}
#     ]

#     # Initialize ETS table for rate limiting
#     :ets.new(:rate_limit_table, [:named_table, :public, :set])

#     # See https://hexdocs.pm/elixir/Supervisor.html
#     # for other strategies and supported options
#     opts = [strategy: :one_for_one, name: ChatApp.Supervisor]
#     Supervisor.start_link(children, opts)
#   end

#   # Tell Phoenix to update the endpoint configuration
#   # whenever the application is updated.
#   @impl true
#   def config_change(changed, _new, removed) do
#     ChatAppWeb.Endpoint.config_change(changed, removed)
#     :ok
#   end
# end
