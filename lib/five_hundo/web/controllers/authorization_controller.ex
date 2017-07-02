defmodule FiveHundo.Web.AuthorizationController do
  use FiveHundo.Web, :controller
  alias FiveHundo.Auth

  def authorize(conn, %{"password" => password}) do
    if Auth.correct_password?(password) do
      conn
      |> Plug.Conn.fetch_session
      |> Plug.Conn.put_session(:authorized, true)
      |> json("authorized")
    else
      json conn, "not authorized"
    end
  end

  def session(conn, _params) do
    if authorized_session?(conn) do
      json(conn, %{
        authorized: true,
      })
    else
      json(conn, %{
        authorized: false,
      })
    end
  end

  def authorized_session?(conn) do
    conn
    |> Plug.Conn.fetch_session
    |> Plug.Conn.get_session(:authorized)
    |> Kernel.!=(nil)
  end

end
