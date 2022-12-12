defmodule Game2048.GamesTest do
  use Game2048.DataCase

  alias Game2048.Games
  alias Game2048.Games.{NewGameForm, Game}

  import Game2048.GamesFixtures

  @invalid_attrs %{grid_size_x: nil, grid_size_y: nil, number_of_obstacles: nil}

  describe "restart_game/1" do
    setup do
      on_exit(:restart_game, fn -> Game.restart() end)
    end

    test "restart_game/1 with valid data restarts the game" do
      valid_attrs = %{grid_size_x: 8, grid_size_y: 8, number_of_obstacles: 4}

      assert {:ok, %NewGameForm{} = new_game_form} = Games.restart_game(valid_attrs)
      assert new_game_form.grid_size_x == 8
      assert new_game_form.grid_size_y == 8
      assert new_game_form.number_of_obstacles == 4
      assert Game.get().grid_size == {8, 8}
    end

    test "restart_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.restart_game(@invalid_attrs)
    end
  end

  describe "change_new_game_form/1" do
    test "change_new_game_form/1 returns a game changeset" do
      new_game_form = new_game_form_fixture()
      assert %Ecto.Changeset{} = Games.change_new_game_form(new_game_form)
    end
  end
end
