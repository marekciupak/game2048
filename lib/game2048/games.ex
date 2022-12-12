defmodule Game2048.Games do
  @moduledoc """
  The Games context.
  """

  alias Game2048.Games.{Game, NewGameForm}

  defdelegate get_game, to: Game, as: :get
  defdelegate move(direction), to: Game, as: :move

  @doc """
  Restarts the game.

  ## Examples

      iex> restart_game(%{field: value})
      {:ok, %NewGameForm{}}

      iex> restart_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def restart_game(attrs \\ %{}) do
    case NewGameForm.changeset(%NewGameForm{}, attrs) do
      %{valid?: true} = changeset ->
        new_game_form = Ecto.Changeset.apply_changes(changeset)

        Game.restart(
          grid_size: NewGameForm.grid_size(new_game_form),
          number_of_obstacles: new_game_form.number_of_obstacles
        )

        {:ok, new_game_form}

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking new game form changes.

  ## Examples

      iex> change_new_game_form(new_game_form)
      %Ecto.Changeset{data: %NewGameForm{}}

  """
  def change_new_game_form(%NewGameForm{} = new_game_form, attrs \\ %{}) do
    NewGameForm.changeset(new_game_form, attrs)
  end
end
