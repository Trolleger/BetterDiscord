defmodule ChatApp.Guardian.AuthErrorHandler do
  @moduledoc """
  Handles authentication errors from Guardian pipeline.
  Returns 401 Unauthorized with JSON error message.
  """
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
