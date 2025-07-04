defmodule ChatApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      prune_code_paths: false,
      compilers: Mix.compilers()
    ]
  end

  def application do
    [
      mod: {ChatApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:gettext, "~> 0.20"},
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:cors_plug, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:ueberauth, "~> 0.10"},
      {:plug_cowboy, "~> 2.6"},
      {:guardian, "~> 2.0"},
      # Add Redis client
      # Add Redis connection pool
      {:guardian_db, "~> 3.0"},
      {:plug_attack, "~> 0.4"},
      {:hackney, "~> 1.9"},
      # TODO: Later on add all the guardian_db functionality, for now we will just be using plain simple guardian
      {:ueberauth_google, "~> 0.12"},
      {:bcrypt_elixir, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
