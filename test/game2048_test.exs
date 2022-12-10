defmodule Game2048Test do
  use ExUnit.Case, async: true
  doctest Game2048

  describe "Game2048.slide/2" do
    test "slides tiles to the left" do
      assert Game2048.slide(
               [
                 [1, 2, 4],
                 [:empty, :empty, 2],
                 [:empty, 2, 2]
               ],
               :left
             ) == [
               [1, 2, 4],
               [2, :empty, :empty],
               [4, :empty, :empty]
             ]
    end

    test "slides tiles to the right" do
      assert Game2048.slide(
               [
                 [1, 2, 4],
                 [:empty, :empty, 2],
                 [:empty, 2, 2]
               ],
               :right
             ) == [
               [1, 2, 4],
               [:empty, :empty, 2],
               [:empty, :empty, 4]
             ]
    end
  end
end
