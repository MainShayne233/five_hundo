defmodule FiveHundo.Web.EntriesController do
  use FiveHundo.Web, :controller
  alias FiveHundo.Entry

  def today(conn, _params) do
    json conn, Entry.for_today()
  end

  def save(conn, %{"entry" => text}) do
    Entry.update_todays_text(text)
    json conn, "success"
  end
end
