defmodule FiveHundo.Web.PageControllerTest do
  use FiveHundo.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello FiveHundo!"
  end
end
