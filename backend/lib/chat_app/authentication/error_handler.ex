defmodule ChatApp.Guardian.AuthErrorHandler do
  # Bascially what we do is call this one and inside we put everything we need to handle the error
  import Plug.Conn
  @behaviour Guardian.Plug.ErrorHandler
  @impl Guardian.Plug.ErrorHandler
  # we import plug.conn, and we add this behavior Guardian.Plug.ErrorHandler and we implement the implement the Guardian.Plug.ErrorHandler
  # These are the things guardian gives us which we need to add to these error_handler files, so if you go to the docs you will see that they say we have to add all of this
  def auth_error(conn,{type, _reason}, _opts) do
    # We define this function, pass the connection, pass the type, hide the reason and the ops (we won't really need them)
    body = Jason.encode!(%{error: to_string(type)})
    # And we add this body variable which is a JSON that is encoded with a message that gives user the error back


    conn
    # With the connection we put the resp connection type as below and send the response as a 401 (unauthorized)
    |> put_resp_content_type("application/json")
    |> send_resp(401,body)
    # And now we already have our error_handler
  end

end
