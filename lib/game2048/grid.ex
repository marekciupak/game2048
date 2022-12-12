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

  @doc """
  Generates a new grid.

  Places the given number of obstacles and given starting tiles in random spots. Leaves the rest of spots empty.

  ## Examples

    iex> Game2048.Grid.generate(size: {3, 2}, number_of_obstacles: 1, starting_tiles: [4, 8])
    [
      [4, 8, :empty],
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
  ## Examples

      iex> Game2048.Grid.place_on_random_empty_spots([
      ...>   [1, 2, 3],
      ...>   [4, 5, :empty],
      ...>   [6, 7, 8]
      ...> ], [:obstacle])
      [
        [1, 2, 3],
        [4, 5, :obstacle],
        [6, 7, 8]
      ]

  """
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

  @doc """
  ## Examples

      iex> Game2048.Grid.empty_spots_positions([
      ...>   [1, 2, :empty],
      ...>   [:empty, :empty, :empty],
      ...>   [3, 4, 5]
      ...> ])
      ...> |> Enum.sort()
      [
        {0, 1},
        {1, 1},
        {2, 0},
        {2, 1}
      ]

  """
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

  @doc """
  ## Examples

  iex> Game2048.Grid.assign_elements_to_positions(
  ...>   [
  ...>     {0, 1},
  ...>     {1, 1},
  ...>     {2, 0},
  ...>     {2, 1}
  ...>   ],
  ...>   [2, 4, 8, :obstacle]
  ...> )
  %{
    {0, 1} => 2,
    {1, 1} => 4,
    {2, 0} => 8,
    {2, 1} => :obstacle
  }

  """
  @spec assign_elements_to_positions(list(spot_position), list(Row.element())) :: %{spot_position => Row.element()}
  defp assign_elements_to_positions(positions, elements) do
    Enum.zip_reduce(positions, elements, %{}, &Map.put(&3, &1, &2))
  end

  @doc """
  ## Examples

  iex> Game2048.Grid.place_on_spots(
  ...>   %{
  ...>     {0, 0} => :obstacle,
  ...>     {0, 1} => 4
  ...>   },
  ...>   [
  ...>     [:empty, :empty],
  ...>     [:empty, :empty]
  ...>   ]
  ...> )
  [
    [:obstacle, :empty],
    [4, :empty]
  ]

  """
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
