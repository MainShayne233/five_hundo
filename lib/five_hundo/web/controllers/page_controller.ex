defmodule FiveHundo.Web.PageController do
  use FiveHundo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
