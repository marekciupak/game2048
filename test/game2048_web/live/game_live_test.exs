defmodule Game2048Web.GameLiveTest do
  use Game2048Web.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    test "Renders the current game", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.game_show_path(conn, :show))

      assert html =~ "obstacle"
    end
  end
end
