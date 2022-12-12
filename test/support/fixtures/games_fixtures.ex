defmodule Game2048.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Game2048.Games` context.
  """

  @doc """
  Generate a new game form.
  """
  def new_game_form_fixture(attrs \\ %{}) do
    {:ok, new_game_form} =
      %Game2048.Games.NewGameForm{}
      |> Game2048.Games.NewGameForm.changeset(
        Enum.into(attrs, %{
          grid_size_x: 6,
          grid_size_y: 6,
          number_of_obstacles: 2
        })
      )
      |> Ecto.Changeset.apply_action(:insert)

    new_game_form
  end
end
