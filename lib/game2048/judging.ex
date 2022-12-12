defmodule Game2048.Judging do
  @moduledoc """
  This module contains the rules that determines whether a game is won or lost, and whether a player can continue
  playing.
  """

  alias Game2048.Grid

  @type game_status :: :ongoing | :won | :lost

  @winning_tile 2048

  @doc """
  Calculates the current status of the game based on the grid.

  Possible game statuses are:
  - `:won`
  - `:ongoing`
  - `:lost`

  ## Examples

    iex> Game2048.Judging.current_game_status([
    ...>   [1, 2, 4],
    ...>   [8, 1, 2],
    ...>   [4, 8, Game2048.Judging.winning_tile]
    ...> ])
    :won

    iex> Game2048.Judging.current_game_status([
    ...>   [1, 2, :obstacle],
    ...>   [8, 1, :empty],
    ...>   [4, 8, 8]
    ...> ])
    :ongoing

    iex> Game2048.Judging.current_game_status([
    ...>   [1, 8, 4],
    ...>   [2, 1, :obstacle],
    ...>   [4, 2, 16]
    ...> ])
    :lost

  """
  @spec current_game_status(Grid.t()) :: game_status
  def current_game_status(grid) do
    cond do
      won?(grid) -> :won
      can_continue?(grid) -> :ongoing
      true -> :lost
    end
  end

  @spec won?(Grid.t()) :: boolean
  defp won?(grid) do
    Grid.any_such_spot_on_grid?(grid, @winning_tile)
  end

  @spec can_continue?(Grid.t()) :: boolean
  defp can_continue?(grid) do
    Grid.any_legal_move_possible?(grid)
  end

  @doc """
  Returns a tile with the number that is required to appear on the grid to win the game.

  ## Examples

  iex> Game2048.Judging.winning_tile()
  2048

  """
  @spec winning_tile :: Row.tile()
  def winning_tile, do: @winning_tile
end
