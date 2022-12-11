defmodule Game2048.Games.Game do
  @enforce_keys [:grid_size, :grid]
  defstruct [:grid_size, :grid]

  use GenServer

  alias Game2048.Games.Game
  alias Game2048.Grid

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

  @impl true
  def init(_options \\ []) do
    grid_size = {3, 3}

    game = %Game{
      grid_size: grid_size,
      grid: Grid.generate(grid_size)
    }

    {:ok, game}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:move, direction}, _from, %Game{grid: grid} = game) do
    grid = Grid.move(grid, direction)
    next_state = Map.put(game, :grid, grid)

    {:reply, next_state, next_state}
  end
end
