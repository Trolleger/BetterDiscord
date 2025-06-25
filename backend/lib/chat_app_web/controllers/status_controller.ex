defmodule ChatAppWeb.StatusController do
  use ChatAppWeb, :controller

  def status(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
