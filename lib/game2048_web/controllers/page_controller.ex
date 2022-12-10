defmodule Game2048Web.PageController do
  use Game2048Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
