defmodule Game2048Web.GameLive.Show do
  use Game2048Web, :live_view

  defguard is_direction(term) when term == "left" or term == "right" or term == "up" or term == "down"

  alias Game2048.Games
  alias Game2048.Games.NewGameForm

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Game2048.Games.subscribe_to_game_updates()

    game = Games.get_game()
    {:ok, assign(socket, :game, game)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "2048 Game")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Restart Game")
    |> assign(:new_game_form, %NewGameForm{})
  end

  @impl true
  def handle_event("move", %{"direction" => direction}, socket) when is_direction(direction) do
    game = Game2048.Games.move(String.to_atom(direction))
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info({:game_updated, game}, socket) do
    {:noreply, assign(socket, :game, game)}
  end
end
