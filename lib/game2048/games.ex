defmodule Game2048.Games do
  @moduledoc """
  The Games context.
  """

  alias Game2048.Games.Game

  defdelegate get_game, to: Game, as: :get
  defdelegate move(direction), to: Game, as: :move
end
