defmodule FiveHundo.Web.EntriesController do
  use FiveHundo.Web, :controller

  def today(conn, _params) do
    json conn, "ayyyyy"
  end

  def save(conn, params) do
    json conn, "success"
  end
end
