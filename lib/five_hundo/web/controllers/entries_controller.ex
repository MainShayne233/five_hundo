defmodule FiveHundo.Web.EntriesController do
  use FiveHundo.Web, :controller

  def save(conn, params) do
    IO.inspect params
    json conn, "success"
  end
end
