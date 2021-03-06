defmodule FiveHundo.Web.AuthorizationController do
  use FiveHundo.Web, :controller
  alias FiveHundo.{Auth, Entry}

  def authorize(conn, %{"password" => password}) do
    if Auth.correct_password?(password) do
      conn
      |> Plug.Conn.fetch_session
      |> Plug.Conn.put_session(:authorized, true)
      |> json(authorized_payload())
    else
      json(conn, not_authorized_payload())
    end
  end


  def session(conn, _params) do
    if authorized_session?(conn) do
      json(conn, authorized_payload())
    else
      json(conn, not_authorized_payload())
    end
  end


  defp authorized_session?(conn) do
    conn
    |> Plug.Conn.fetch_session
    |> Plug.Conn.get_session(:authorized)
    |> Kernel.==(true)
  end


  defp authorized_payload do
    %{
      authorized: true,
      breakdown: Entry.breakdown(),
      entry: Entry.todays_entry(),
    }
  end


  defp not_authorized_payload do
    %{
      authorized: false,
      breakdown: [],
      entry: "",
    }
  end
end
