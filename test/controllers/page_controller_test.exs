defmodule Connectdemo.PageControllerTest do
  use Connectdemo.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
