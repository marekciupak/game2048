defmodule Game2048.Games.Game do
  @enforce_keys [:grid_size, :grid, :status]
  defstruct [:grid_size, :grid, :status]

  use GenServer

  alias Game2048.Games.Game
  alias Game2048.{Grid, Judging}

  def start_link(options \\ []) when is_list(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @doc """
  Gets the current game.

  ## Examples

      iex> Game2048.Games.Game.get()
      %Game2048.Games.Game{
        grid_size: {3, 3},
        grid: [
          [:empty, 2, :empty],
          [:empty, :empty, 4],
          [1, :obstacle, :empty]
        ]
      }

  """
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def move(direction) do
    GenServer.call(__MODULE__, {:move, direction})
  end

  @doc """
  Restarts the game.

  Optionally, you can specify custom gameplay parameters (grid size and number of obstacles) for the new game.

  ## Examples

      iex> Game2048.Games.Game.restart(
        grid_size: {3, 3},
        number_of_obstacles: 1
      )
      %Game2048.Games.Game{
        grid_size: {3, 3},
        grid: [
          [:empty, 2, :empty],
          [:empty, :empty, 4],
          [1, :obstacle, :empty]
        ]
      }

  """
  def restart(params \\ []) do
    GenServer.call(__MODULE__, {:restart, params})
  end

  @impl true
  def init(params \\ []) do
    game = generate_new_game(params)

    {:ok, game}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:move, direction}, _from, %Game{status: :ongoing, grid: grid} = game) do
    next_grid = Grid.move(grid, direction)

    next_game =
      Map.merge(game, %{
        grid: next_grid,
        status: Judging.current_game_status(next_grid)
      })

    {:reply, next_game, next_game}
  end

  # TODO: Consider replying with explicit error when :move requested for illegal move (ex. when game is already lost or
  # won).
  @impl true
  def handle_call({:move, _direction}, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call({:restart, params}, _from, _game) do
    game = generate_new_game(params)

    {:reply, game, game}
  end

  defp generate_new_game(params) do
    grid_size = Keyword.get(params, :grid_size, {6, 6})
    number_of_obstacles = Keyword.get(params, :number_of_obstacles, 2)

    grid =
      Grid.generate(
        size: grid_size,
        number_of_obstacles: number_of_obstacles,
        starting_tiles: [1]
      )

    %Game{
      grid_size: grid_size,
      grid: grid,
      status: Judging.current_game_status(grid)
    }
  end
end
