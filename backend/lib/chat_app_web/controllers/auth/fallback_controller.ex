defmodule ChatAppWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ChatAppWeb, :controller

  # Handle Ecto changeset errors
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ChatAppWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # Handle not found errors
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: ChatAppWeb.ErrorHTML, json: ChatAppWeb.ErrorJSON)
    |> render(:"404")
  end

  # Handle authentication errors - user not found
  def call(conn, {:error, :user_not_found}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Invalid credentials"})
  end

  # Handle authentication errors - invalid password
  def call(conn, {:error, :invalid_password}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Invalid credentials"})
  end

  # Catch-all for any other errors
  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "Internal server error"})
  end
end
