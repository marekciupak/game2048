defmodule Game2048.Grid do
  @moduledoc """
  Grid consisting of rows and columns written as follows:

      [
        [2, 4, 8],
        [2, :empty, :obstacle]
        [:empty, 16, 16]
      ]

  Each row (or column) consists of spots.

  Spot can:
  - be empty (`:empty`),
  - contain a numbered tile (one of: `1`, `2`, `4`, `8`, `16`, `32`, and so on),
  - contain an obstacle (`:obstacle`).
  """

  alias Game2048.Grid.Row

  @type t :: list(Row.t())
  @type size_x :: pos_integer()
  @type size_y :: pos_integer()
  @type size :: {size_x, size_y}
  @type direction :: :left | :right | :up | :down

  @doc """
  Generates a new grid.
  """
  @spec generate(size) :: t
  def generate({3, 3}) do
    [
      [:empty, 2, :empty],
      [:empty, :empty, 4],
      [1, :obstacle, :empty]
    ]
  end

  @doc """
  Makes the player's move on the grid.

  Player can move the gird in one of the four directions (`:left`, `:right`, `:up` or `:down`).

  The movement causes sliding all the tiles in the grid to a given direction.

  The rules for sliding tiles in a single row are described in `Game2048.Row.slide_left/2` and
  `Game2048.Row.slide_right/2`. The rules for sliding the tiles in columns are exactly the same, apart from the
  difference in directions. The rules will be applied to each individual row (directions `:left` or `:right`) or column
  (directions `:up` or `:down`).

  ## Examples

    iex>Game2048.Grid.move(
    ...>  [
    ...>    [:empty, :empty, 2],
    ...>    [:empty, 2, 2],
    ...>    [2, :empty, 4]
    ...>  ],
    ...>  :left
    ...>)
    [
      [2, :empty, :empty],
      [4, :empty, :empty],
      [2, 4, :empty]
    ]

    iex Game2048.Grid.move(
    ...>   [
    ...>     [:empty, :empty, 2],
    ...>     [:empty, :obstacle, 2],
    ...>     [2, :empty, 4]
    ...>   ],
    ...>   :down
    ...> )
    [
      [:empty, :empty, :empty],
      [:empty, :obsctale, 4],
      [2, 2, 4]
    ]

  """
  @spec move(t, direction) :: t
  def move(grid, direction) do
    grid
    |> slide(direction)
  end

  @spec slide(t, direction) :: t
  defp slide(grid, :right) do
    grid
    |> Enum.map(&Row.slide_right/1)
  end

  defp slide(grid, :left) do
    grid
    |> Enum.map(&Row.slide_left/1)
  end

  defp slide(grid, :up) do
    grid
    |> transpose()
    |> Enum.map(&Row.slide_left/1)
    |> transpose()
  end

  defp slide(grid, :down) do
    grid
    |> transpose()
    |> Enum.map(&Row.slide_right/1)
    |> transpose()
  end

  # https://en.wikipedia.org/wiki/Transpose
  @spec transpose(t) :: t
  defp transpose(grid) do
    grid
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
