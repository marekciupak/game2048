defmodule Game2048.Games.NewGameForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:grid_size_x, :integer, default: 6)
    field(:grid_size_y, :integer, default: 6)
    field(:number_of_obstacles, :integer, default: 2)
  end

  @doc false
  def changeset(new_game_form, attrs) do
    new_game_form
    |> cast(attrs, [:grid_size_x, :grid_size_y, :number_of_obstacles])
    |> validate_required([:grid_size_x, :grid_size_y, :number_of_obstacles])
    |> validate_number(:grid_size_x, greater_than_or_equal_to: 1)
    |> validate_number(:grid_size_y, greater_than_or_equal_to: 1)
    |> validate_number(:number_of_obstacles, greater_than_or_equal_to: 0)
  end

  def grid_size(%{grid_size_x: x, grid_size_y: y}), do: {x, y}
end
