defmodule Game2048.Grid.RowTest do
  use ExUnit.Case, async: true
  doctest Game2048.Grid.Row

  describe "Game2048.Grid.Row.slide_left/1" do
    test "does not change empty rows" do
      assert Game2048.Grid.Row.slide_left([]) == []
      assert Game2048.Grid.Row.slide_left([:empty, :empty, :empty]) == [:empty, :empty, :empty]
    end

    test "does not moves tiles that are already on the left" do
      assert Game2048.Grid.Row.slide_left([1, :empty, :empty]) == [1, :empty, :empty]
      assert Game2048.Grid.Row.slide_left([1, 2]) == [1, 2]
      assert Game2048.Grid.Row.slide_left([1, 2, :empty]) == [1, 2, :empty]
    end

    test "moves a single tile to the left" do
      assert Game2048.Grid.Row.slide_left([:empty, 1, :empty]) == [1, :empty, :empty]
      assert Game2048.Grid.Row.slide_left([:empty, :empty, 1, :empty, :empty]) == [1, :empty, :empty, :empty, :empty]
    end

    test "moves multiple tiles to the left" do
      assert Game2048.Grid.Row.slide_left([:empty, 1, 2]) == [1, 2, :empty]
      assert Game2048.Grid.Row.slide_left([:empty, 2, :empty, :empty, 8]) == [2, 8, :empty, :empty, :empty]
      assert Game2048.Grid.Row.slide_left([2, :empty, 8, :empty]) == [2, 8, :empty, :empty]
    end

    test "moves tiles to the left merging matching pairs together" do
      assert Game2048.Grid.Row.slide_left([1, 1]) == [2, :empty]
      assert Game2048.Grid.Row.slide_left([1, 1, 1, 1]) == [2, 2, :empty, :empty]
      assert Game2048.Grid.Row.slide_left([1, 1, 1, 1, 1]) == [2, 2, 1, :empty, :empty]
      assert Game2048.Grid.Row.slide_left([1, 1, 2]) == [2, 2, :empty]
      assert Game2048.Grid.Row.slide_left([:empty, 1, :empty, :empty, 1]) == [2, :empty, :empty, :empty, :empty]
    end
  end

  describe "Game2048.Grid.Row.slide_right/1" do
    test "does not change empty rows" do
      assert Game2048.Grid.Row.slide_right([]) == []
      assert Game2048.Grid.Row.slide_right([:empty, :empty, :empty]) == [:empty, :empty, :empty]
    end

    test "does not moves tiles that are already on the right" do
      assert Game2048.Grid.Row.slide_right([:empty, 2, 4]) == [:empty, 2, 4]
    end

    test "moves a single tile to the right" do
      assert Game2048.Grid.Row.slide_right([1, :empty, :empty]) == [:empty, :empty, 1]
    end

    test "moves multiple tiles to the right" do
      assert Game2048.Grid.Row.slide_right([1, :empty, :empty, 8, :empty]) == [:empty, :empty, :empty, 1, 8]
    end

    test "moves tiles to the right merging matching pairs together" do
      assert Game2048.Grid.Row.slide_right([8, 8, 8, 8, 8]) == [:empty, :empty, 8, 16, 16]
      assert Game2048.Grid.Row.slide_right([8, 8, :empty, :empty]) == [:empty, :empty, :empty, 16]
    end
  end
end
