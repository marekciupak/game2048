defmodule Game2048Web.GameLiveTest do
  use Game2048Web.ConnCase

  import Phoenix.LiveViewTest

  alias Game2048.Games.Game

  @create_attrs %{grid_size_x: 2, grid_size_y: 2, number_of_obstacles: 1}

  describe "Show" do
    setup do
      on_exit(:restart_game, fn -> Game.restart() end)
    end

    test "Renders the current game", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, Routes.game_show_path(conn, :show))

      assert html =~ "<div class=\"spot\"></div>"
    end

    test "restarts a game", %{conn: conn} do
      {:ok, show_live, _html} = live(conn, Routes.game_show_path(conn, :show))

      assert show_live |> element("a", "restart the game") |> render_click() =~
               "restart the game"

      assert_patch(show_live, Routes.game_show_path(conn, :new))

      {:ok, _, html} =
        show_live
        |> form("#new-game-form", new_game_form: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.game_show_path(conn, :show))

      assert html =~ "A new game has started. Good luck!"
    end
  end
end
