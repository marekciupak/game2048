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
  - contain a numbered tile,
  - contain an obstacle (`:obstacle`).
  """

  alias Game2048.Grid.{Row, Obstacles, NotEnoughSpotsError}

  @type t :: list(Row.t())
  @type size :: {pos_integer(), pos_integer()}
  @type spot_position_x :: pos_integer()
  @type spot_position_y :: pos_integer()
  @type spot_position :: {spot_position_x, spot_position_y}
  @type direction :: :left | :right | :up | :down

  @tile_that_appears_on_every_move 1

  @doc """
  Generates a new grid.

  Places the given number of obstacles and given starting tiles in random spots. Leaves the rest of spots empty.

  ## Examples

    iex> Game2048.Grid.generate(size: {3, 2}, number_of_obstacles: 1, starting_tiles: [4, 8])
    [
      [4, :empty, 8],
      [:empty, :obstacle, :empty]
    ]
  """
  @spec generate(size: size, number_of_obstacles: pos_integer(), starting_tiles: list(Row.tile())) :: t
  def generate(size: size, number_of_obstacles: number_of_obstacles, starting_tiles: starting_tiles) do
    starting_elements = Obstacles.build_collection(number_of_obstacles) ++ starting_tiles

    size
    |> generate_empty_grid()
    |> place_on_random_empty_spots(starting_elements)
  end

  @spec generate_empty_grid(size) :: t
  defp generate_empty_grid({size_x, size_y}) do
    :empty
    |> List.duplicate(size_x)
    |> List.duplicate(size_y)
  end

  @doc """
  Makes the player's move on the grid.

  The movement consists of two steps:

  1. Sliding all the tiles in the gird in direction selected by a player (`:left`, `:right`, `:up` or `:down`).

  The rules for sliding tiles in a single row are described in `Game2048.Row.slide_left/2` and
  `Game2048.Row.slide_right/2`. The rules for sliding the tiles in columns are exactly the same, apart from the
  difference in directions. The rules will be applied to each individual row (directions `:left` or `:right`) or column
  (directions `:up` or `:down`).

  2. A new tile with number 1 appears in a random empty spot on the grid.

  It may happen that a given move is illegal (a slide in a given direction does not cause any changes on the grid) -
  in this case the function returns the grid without any changes.

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
      [2, :empty, 1],
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
      [1, :obsctale, 4],
      [2, 2, 4]
    ]

  """
  @spec move(t, direction) :: t
  def move(grid, direction) do
    grid
    |> slide(direction)
    |> add_new_tile_if_grid_has_changed(prev_grid: grid)
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

  @spec add_new_tile_if_grid_has_changed(t, prev_grid: t) :: t
  defp add_new_tile_if_grid_has_changed(current_grid, prev_grid: prev_grid) do
    if current_grid != prev_grid do
      place_on_random_empty_spots(current_grid, [@tile_that_appears_on_every_move])
    else
      current_grid
    end
  end

  @spec place_on_random_empty_spots(t, list(Row.element())) :: t
  defp place_on_random_empty_spots(grid, elements) do
    number_of_elements = Enum.count(elements)

    grid
    |> empty_spots_positions()
    |> ensure_enough_spots!(number_of_elements)
    |> Enum.take_random(number_of_elements)
    |> assign_elements_to_positions(elements)
    |> place_on_spots(grid)
  end

  @spec empty_spots_positions(t) :: list(spot_position)
  defp empty_spots_positions(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      empty_spots_positions(row, y, acc)
    end)
  end

  @spec empty_spots_positions(Row.t(), spot_position_y, list(spot_position)) :: list(spot_position)
  defp empty_spots_positions(row, y, acc) do
    row
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {spot, x}, acc ->
      case spot do
        :empty -> [{x, y} | acc]
        _ -> acc
      end
    end)
  end

  # TODO: Consider implementing a more advanced error handling and return errors instead of raising exceptions.
  @spec ensure_enough_spots!(list(spot_position), pos_integer()) :: list(spot_position)
  defp ensure_enough_spots!(spots_positions, minimal_number) do
    if(Enum.count(spots_positions) < minimal_number, do: raise(NotEnoughSpotsError))

    spots_positions
  end

  @spec assign_elements_to_positions(list(spot_position), list(Row.element())) :: %{spot_position => Row.element()}
  defp assign_elements_to_positions(positions, elements) do
    Enum.zip_reduce(positions, elements, %{}, &Map.put(&3, &1, &2))
  end

  @spec place_on_spots(%{spot_position => Row.element()}, t) :: t
  defp place_on_spots(positions_and_elements, grid) do
    Enum.with_index(grid, fn row, y ->
      Enum.with_index(row, fn spot, x ->
        place_on_spot(positions_and_elements, {x, y}, spot)
      end)
    end)
  end

  @spec place_on_spot(%{spot_position => Row.element()}, spot_position, Row.spot()) :: t
  defp place_on_spot(positions_and_elements, position, spot) do
    case Map.fetch(positions_and_elements, position) do
      {:ok, fetched_element} -> fetched_element
      :error -> spot
    end
  end

  @doc """
  Checks whether any legal move is possible on the given grid.

  The move is illegal when there are no empty spots and no adjacent tiles with the same value.

  ## Examples

    iex> Game2048.Grid.any_legal_move_possible?([
    ...>   [1, 2, 4],
    ...>   [8, 1, 2],
    ...>   [4, 8, 1]
    ...> ])
    false

    iex> Game2048.Grid.any_legal_move_possible?([
    ...>   [1, 2, 4],
    ...>   [8, 1, 2],
    ...>   [4, 8, 8]
    ...> ])
    true

  """
  @spec any_legal_move_possible?(t) :: boolean
  def any_legal_move_possible?(grid) do
    any_such_spot_on_grid?(grid, :empty) || any_slide_changes_the_grid?(grid)
  end

  @doc """
  Checks whether there is at least one spot with the given value on the grid.

  ## Examples

    iex Game2048.Grid.any_such_spot_on_grid?(
    ...>   [
    ...>     [:empty, :empty, 2],
    ...>     [:empty, :obstacle, 2],
    ...>     [2, :empty, 4]
    ...>   ],
    ...>   :obstacle
    ...> )
    true

    iex Game2048.Grid.any_such_spot_on_grid?(
    ...>   [
    ...>     [:empty, :empty, 2],
    ...>     [:empty, :obstacle, 2],
    ...>     [2, :empty, 4]
    ...>   ],
    ...>   8
    ...> )
    false

  """
  @spec any_such_spot_on_grid?(t, Row.spot()) :: boolean
  def any_such_spot_on_grid?(grid, spot) do
    Enum.any?(grid, fn row ->
      Enum.any?(row, fn actual_spot ->
        actual_spot == spot
      end)
    end)
  end

  @spec any_slide_changes_the_grid?(t) :: boolean
  defp any_slide_changes_the_grid?(grid) do
    [:right, :left, :up, :down]
    |> Enum.any?(&does_slide_change_the_grid?(grid, &1))
  end

  @spec does_slide_change_the_grid?(t, direction) :: boolean
  defp does_slide_change_the_grid?(grid, direction) do
    grid != slide(grid, direction)
  end

  @doc """
  Returns a tile with the number that appears on a grid on every player's move.

  ## Examples

  iex> Game2048.Grid.tile_that_appears_on_every_move()
  1

  """
  @spec tile_that_appears_on_every_move :: Row.tile()
  def tile_that_appears_on_every_move, do: @tile_that_appears_on_every_move
end
