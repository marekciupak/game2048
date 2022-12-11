defmodule Game2048.Grid do
  @moduledoc """
  Documentation for `Game2048.Grid`.
  """

  def generate({3, 3}) do
    [
      [:empty, 2, :empty],
      [:empty, :empty, 4],
      [1, :obstacle, :empty]
    ]
  end
end
