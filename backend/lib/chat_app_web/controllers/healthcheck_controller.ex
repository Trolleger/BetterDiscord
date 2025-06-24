defmodule ChatAppWeb.HealthcheckController do
  use ChatAppWeb, :controller
  # Set's up the module like a controller
  def index(conn, _params) do
    # conn is the entire connection struct representing the HTTP request and response.
    # It holds everything: request data (headers, params, method), and also lets you build the response step-by-step.
    # It’s how Phoenix passes the request context into your controller.

    # We name the function index becaause it matches the Phoenix convention for “return the main resource or status.”
    # It's just the Phoenix Standard name for the Get function you know?

    send_resp(conn, 200, "OK")
    # This code takes 3 arguments nothing fancy really it sends an HTTP response back to whoever made the request with the information It’s like you’re saying:
    # “Here’s your connection, mark it as successful, give you this ‘OK’ text, and send it now.”
    # They are Conn (Which explanation is of above) 200 which is the http code for Okay, you're good, and "OK" is just to keep it lightweight and nice
  end
end
