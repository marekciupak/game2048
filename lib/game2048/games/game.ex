defmodule Game2048.Games.Game do
  @enforce_keys [:grid_size, :grid, :status]
  defstruct [:grid_size, :grid, :status]

  use GenServer

  alias Game2048.Games.Game
  alias Game2048.{Grid, Judging}

  @type t :: %__MODULE__{grid_size: Grid.size(), grid: Grid.t(), status: Judging.game_status()}

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
  @spec get :: t
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @doc """
  Executes player's move.

  Player can move tiles in one of 4 directions (`:left`, `:right`, `:up` or `:down`).

  It will update the grid (for details, see `Game2048.Grid.move/2`) and game status (for details, see
  `Game2048.Judging.current_game_status/1`).

  ## Examples

      iex> Game2048.Games.Game.move(:left)
      %Game2048.Games.Game{
        grid_size: {3, 3},
        grid: [
          [:obstacle, 1, :empty],
          [1, :empty, :empty],
          [:empty, :empty, :empty]
        ],
        status: :ongoing
      }

  """
  @spec move(Grid.direction()) :: t
  def move(direction) do
    GenServer.call(__MODULE__, {:move, direction})
  end

  @doc """
  Restarts the game.

  Optionally, you can specify custom gameplay parameters (grid size and number of obstacles) for the new game.

  ## Examples

      iex> Game2048.Games.Game.restart(
      ...>   grid_size: {3, 3},
      ...>   number_of_obstacles: 1
      ...> )
      %Game2048.Games.Game{
        grid_size: {3, 3},
        grid: [
          [:empty, 2, :empty],
          [:empty, :empty, 4],
          [1, :obstacle, :empty]
        ]
      }

  """
  @spec restart(grid_size: Grid.size(), number_of_obstacles: pos_integer()) :: t
  def restart(params \\ []) do
    GenServer.call(__MODULE__, {:restart, params})
  end

  @doc """
  Subscribe to game's updates.

  """
  @spec subscribe :: :ok | {:error, {:already_registered, pid}}
  def subscribe do
    Phoenix.PubSub.subscribe(Game2048.PubSub, "game")
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

    broadcast(next_game)

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

    broadcast(game)

    {:reply, game, game}
  end

  @spec generate_new_game(grid_size: Grid.size(), number_of_obstacles: pos_integer()) :: t
  defp generate_new_game(params) do
    grid_size = Keyword.get(params, :grid_size, {6, 6})
    number_of_obstacles = Keyword.get(params, :number_of_obstacles, 2)

    grid =
      Grid.generate(
        size: grid_size,
        number_of_obstacles: number_of_obstacles,
        starting_tiles: [2]
      )

    %Game{
      grid_size: grid_size,
      grid: grid,
      status: Judging.current_game_status(grid)
    }
  end

  @spec broadcast(t) :: :ok | {:error, any}
  defp broadcast(game) do
    Phoenix.PubSub.broadcast(Game2048.PubSub, "game", {:game_updated, game})
  end
end
