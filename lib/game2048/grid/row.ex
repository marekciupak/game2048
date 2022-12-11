defmodule Game2048.Grid.Row do
  @moduledoc """
  Row consis spots and is written as follows:

      [2, 1, 4, 8, :empty, :obstacle, 64]

  Spot can:
  - be empty (`:empty`),
  - contain a numbered tile,
  - contain an obstacle (`:obstacle`).
  """

  @type t :: list(spot)
  @type spot :: empty_spot | obstacle | tile
  @type empty_spot :: :empty
  @type obstacle :: :obstacle
  @type tile :: pos_integer()

  @doc """
  Slides tiles as far as possible to the left. Tiles can slide through empty spots and can move other tiles until they
  are stopped by an obstacle or the edge of the row.

  If two tiles of the same number collide while moving, they will merge into a tile with the total value of the two
  tiles that collided. The resulting tile cannot merge with another tile again.

  Obstacles do not move.

  ## Examples

      iex> Game2048.Grid.Row.slide_left([:empty, 1, 2, :empty, 4])
      [1, 2, 4, :empty, :empty]

      iex> Game2048.Grid.Row.slide_left([2, 2, :empty, 4, 4])
      [4, 8, :empty, :empty, :empty]

      iex> Game2048.Grid.Row.slide_left([8, 8, 8])
      [16, 8, :empty]

      iex> Game2048.Grid.Row.slide_left([:empty, 2, :obstacle, :empty, 4, 4])
      [2, :empty, :obstacle, 8, :empty, :empty]

  """
  @spec slide_left(t) :: t
  def slide_left(row) do
    row
    |> slide()
    |> Enum.reverse()
  end

  @doc """
  Slides tiles as far as possible to the right.

  All the rules are the same as when sliding to the left (only the direction is different) - take a look at
  `Game2048.Grid.Row.slide_left/1` for details.

  ## Examples

      iex> Game2048.Grid.Row.slide_right([:empty, 1, 2, :empty, 4])
      [:empty, :empty, 1, 2, 4]

      iex> Game2048.Grid.Row.slide_right([2, 2, 2, :obstacle, 4, 4])
      [:empty, 2, 4, :obstacle, :empty, 8]

  """
  @spec slide_right(t) :: t
  def slide_right(row) do
    row
    |> Enum.reverse()
    |> slide()
  end

  @spec slide(t, list(t), list(empty_spot)) :: t
  defp slide(_row, acc \\ [], empty_spots \\ [])

  defp slide([:obstacle | rest], acc, empty_spots) do
    acc = empty_spots ++ acc
    slide(rest, [:obstacle | acc], [])
  end

  defp slide([:empty | rest], acc, empty_spots) do
    slide(rest, acc, [:empty | empty_spots])
  end

  defp slide([tile, :empty | rest], acc, empty_spots) do
    slide([tile | rest], acc, [:empty | empty_spots])
  end

  defp slide([tile, tile | rest], acc, empty_spots) do
    merged_tile = 2 * tile
    slide(rest, [merged_tile | acc], [:empty | empty_spots])
  end

  defp slide([tile | rest], acc, empty_spots) do
    slide(rest, [tile | acc], empty_spots)
  end

  defp slide([], acc, empty_spots) do
    empty_spots ++ acc
  end
end
