defmodule FiveHundo.Web.EntriesController do
  use FiveHundo.Web, :controller
  alias FiveHundo.Entry


  def save(conn, %{"entry" => text}) do
    Entry.update_todays_text(text)
    json conn, "success"
  end
end
