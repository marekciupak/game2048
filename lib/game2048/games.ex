defmodule Game2048.Games do
  @moduledoc """
  This module is responsible for managing games (storing the game state and processing commands from players, etc.).
  """

  alias Game2048.Games.{Game, NewGameForm}

  @spec get_game :: Game.t()
  defdelegate get_game, to: Game, as: :get

  @spec move(Grid.direction()) :: Game.t()
  defdelegate move(direction), to: Game, as: :move

  @spec subscribe_to_game_updates :: :ok | {:error, {:already_registered, pid}}
  defdelegate subscribe_to_game_updates, to: Game, as: :subscribe

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
