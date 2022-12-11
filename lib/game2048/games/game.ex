defmodule Game2048.Games.Game do
  @enforce_keys [:grid_size, :grid]
  defstruct [:grid_size, :grid]

  alias Game2048.Games.Game

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
    %Game{
      grid_size: {3, 3},
      grid: [
        [:empty, 2, :empty],
        [:empty, :empty, 4],
        [1, :obstacle, :empty]
      ]
    }
  end
end
