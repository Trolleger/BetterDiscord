defmodule ChatAppWeb.StatusController do
  use ChatAppWeb, :controller

  # GET /api/status
  def status(conn, _params) do
    json(conn, %{})
  end
end
