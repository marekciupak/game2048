defmodule Game2048Web.GameLive.Show do
  use Game2048Web, :live_view

  alias Game2048.Games

  @impl true
  def mount(_params, _session, socket) do
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

  @impl true
  def handle_event("move", %{"direction" => direction}, socket) do
    IO.inspect(direction)

    {:noreply, socket}
  end
end
