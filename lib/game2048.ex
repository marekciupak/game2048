defmodule Game2048 do
  @moduledoc """
  Documentation for `Game2048`.
  """

  alias Game2048.Row

  @doc """
  Slides tiles as far as possible in the given direction.

  ## Examples

      iex> Game2048.slide(
      ...>   [
      ...>     [:empty, 2, :empty],
      ...>     [2, 2, 2],
      ...>     [2, 8, 4]
      ...>   ],
      ...>   :left
      ...> )
      [
        [2, :empty, :empty],
        [4, 2, :empty],
        [2, 8, 4]
      ]

  """
  def slide(grid, :left) do
    Enum.map(grid, &Row.slide_left(&1))
  end

  def slide(grid, :right) do
    Enum.map(grid, &Row.slide_right(&1))
  end
end
