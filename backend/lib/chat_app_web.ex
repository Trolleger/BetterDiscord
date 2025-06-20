defmodule ChatAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels, and so on.

  Usage:
      use ChatAppWeb, :controller
      use ChatAppWeb, :view
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: ChatAppWeb.Layouts]

      use Gettext, backend: ChatAppWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/chat_app_web/templates",
        namespace: ChatAppWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Basic imports and aliases for views
      import Phoenix.View

      use Phoenix.HTML
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ChatAppWeb.Endpoint,
        router: ChatAppWeb.Router,
        statics: ChatAppWeb.static_paths()
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
