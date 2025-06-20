defmodule ChatAppWeb do
  @moduledoc """
  Entrypoint for your API‑only backend. No HTML, no layouts.
  """

  def router do
    quote do
      use Phoenix.Router, helpers: false
      import Plug.Conn
      import Phoenix.Controller
      unquote(verified_routes())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      # JSON only, no layouts clause
      use Phoenix.Controller,
        formats: [:json]

      import Plug.Conn
      import ChatAppWeb.Gettext
      unquote(verified_routes())
    end
  end

  def json do
    quote do
      import Plug.Conn
      import Phoenix.Controller, only: [render: 2, render: 3]
      import ChatAppWeb.Gettext
      alias ChatAppWeb.Router.Helpers, as: Routes
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ChatAppWeb.Endpoint,
        router: ChatAppWeb.Router,
        statics: []
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
