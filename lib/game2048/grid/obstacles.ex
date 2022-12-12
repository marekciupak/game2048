defmodule Game2048.Grid.Obstacles do
  @moduledoc """
  Obstacles.
  """

  @type t :: :obstacle

  @doc """
  Returns a list containing a given number of obstacles.

  ## Examples

      iex> Game2048.Grid.Obstacles.build_collection(3)
      [:obstacle, :obstacle, :obstacle]

      iex> Game2048.Grid.Obstacles.build_collection(0)
      []

  """
  @spec build_collection(non_neg_integer()) :: list(t)
  def build_collection(quantity) do
    List.duplicate(:obstacle, quantity)
  end
end
