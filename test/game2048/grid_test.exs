defmodule Game2048.GridTest do
  use ExUnit.Case, async: true
  doctest Game2048.Grid

  describe "Game2048.Grid.move/2" do
    test "slides tiles to the left" do
      assert(
        Game2048.Grid.move(
          [
            [2, :empty, 2],
            [16, :obstacle, 16],
            [:empty, 2, 32]
          ],
          :left
        ) == [
          [4, :empty, :empty],
          [16, :obstacle, 16],
          [2, 32, :empty]
        ]
      )
    end

    test "slides tiles to the right" do
      assert(
        Game2048.Grid.move(
          [
            [2, :empty, 2],
            [16, 16, 16],
            [:empty, 2, 32]
          ],
          :right
        ) == [
          [:empty, :empty, 4],
          [:empty, 16, 32],
          [:empty, 2, 32]
        ]
      )
    end

    test "slides tiles up" do
      assert(
        Game2048.Grid.move(
          [
            [2, :empty, 2],
            [16, :obstacle, 16],
            [:empty, 2, 32]
          ],
          :up
        ) == [
          [2, :empty, 2],
          [16, :obstacle, 16],
          [:empty, 2, 32]
        ]
      )
    end

    test "slides tiles down" do
      assert(
        Game2048.Grid.move(
          [
            [2, :empty, 2],
            [16, 16, 16],
            [:empty, 2, 32]
          ],
          :down
        ) == [
          [:empty, :empty, 2],
          [2, 16, 16],
          [16, 2, 32]
        ]
      )
    end
  end
end
