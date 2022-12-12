defmodule Game2048.GridTest do
  use ExUnit.Case, async: true
  doctest Game2048.Grid, except: [generate: 1, move: 2]

  import Game2048.Grid, only: [tile_that_appears_on_every_move: 0]

  describe "Game2048.Grid.generate/1" do
    test "generates empty grid" do
      assert(
        Game2048.Grid.generate(
          size: {2, 2},
          number_of_obstacles: 0,
          starting_tiles: []
        ) == [
          [:empty, :empty],
          [:empty, :empty]
        ]
      )
    end

    test "generates grid with obstacles and starting tiles" do
      assert(
        Game2048.Grid.generate(
          size: {2, 2},
          number_of_obstacles: 1,
          starting_tiles: [2, 4]
        )
        |> List.flatten()
        |> Enum.sort() == [2, 4, :empty, :obstacle]
      )
    end

    test "raises NotEnoughSpotsError when there is no enough spots for the given elements in the grid" do
      assert_raise(
        Game2048.Grid.NotEnoughSpotsError,
        fn ->
          Game2048.Grid.generate(
            size: {2, 2},
            number_of_obstacles: 2,
            starting_tiles: [2, 4, 8]
          )
        end
      )
    end
  end

  describe "Game2048.Grid.move/2" do
    def reject_elements(grid, element) do
      Enum.map(grid, fn row ->
        Enum.map(row, fn spot ->
          if spot == element do
            :empty
          else
            spot
          end
        end)
      end)
    end

    test "slides tiles to the left" do
      grid =
        [
          [2, :empty, 2],
          [16, :obstacle, 16],
          [:empty, 2, 32]
        ]
        |> Game2048.Grid.move(:left)
        |> reject_elements(tile_that_appears_on_every_move())

      assert grid == [
               [4, :empty, :empty],
               [16, :obstacle, 16],
               [2, 32, :empty]
             ]
    end

    test "slides tiles to the right" do
      grid =
        [
          [2, :empty, 2],
          [16, 16, 16],
          [:empty, 2, 32]
        ]
        |> Game2048.Grid.move(:right)
        |> reject_elements(tile_that_appears_on_every_move())

      assert grid == [
               [:empty, :empty, 4],
               [:empty, 16, 32],
               [:empty, 2, 32]
             ]
    end

    test "slides tiles up" do
      grid =
        [
          [2, :empty, 2],
          [16, :obstacle, 16],
          [:empty, 2, 32]
        ]
        |> Game2048.Grid.move(:up)
        |> reject_elements(tile_that_appears_on_every_move())

      assert grid == [
               [2, :empty, 2],
               [16, :obstacle, 16],
               [:empty, 2, 32]
             ]
    end

    test "slides tiles down" do
      grid =
        [
          [2, :empty, 2],
          [16, 16, 16],
          [:empty, 2, 32]
        ]
        |> Game2048.Grid.move(:down)
        |> reject_elements(tile_that_appears_on_every_move())

      assert grid == [
               [:empty, :empty, 2],
               [2, 16, 16],
               [16, 2, 32]
             ]
    end

    test "adds new tile after a slide" do
      grid =
        [
          [2, 4, 8],
          [16, :obstacle, 32],
          [64, :empty, 128]
        ]
        |> Game2048.Grid.move(:right)

      assert grid == [
               [2, 4, 8],
               [16, :obstacle, 32],
               [tile_that_appears_on_every_move(), 64, 128]
             ]
    end

    test "does nothing for illegal move" do
      grid =
        [
          [2, 4, 8],
          [16, :obstacle, 32],
          [64, :empty, 128]
        ]
        |> Game2048.Grid.move(:up)

      assert grid == [
               [2, 4, 8],
               [16, :obstacle, 32],
               [64, :empty, 128]
             ]
    end
  end
end
