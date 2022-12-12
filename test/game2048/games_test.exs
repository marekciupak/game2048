defmodule Game2048.GamesTest do
  use Game2048.DataCase

  alias Game2048.Games

  describe "games" do
    alias Game2048.Games.NewGameForm

    import Game2048.GamesFixtures

    @invalid_attrs %{grid_size_x: nil, grid_size_y: nil, number_of_obstacles: nil}

    test "restart_game/1 with valid data restarts the game" do
      valid_attrs = %{grid_size_x: 42, grid_size_y: 42, number_of_obstacles: 42}

      assert {:ok, %NewGameForm{} = new_game_form} = Games.restart_game(valid_attrs)
      assert new_game_form.grid_size_x == 42
      assert new_game_form.grid_size_y == 42
      assert new_game_form.number_of_obstacles == 42
    end

    test "restart_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.restart_game(@invalid_attrs)
    end

    test "change_new_game_form/1 returns a game changeset" do
      new_game_form = new_game_form_fixture()
      assert %Ecto.Changeset{} = Games.change_new_game_form(new_game_form)
    end
  end
end
