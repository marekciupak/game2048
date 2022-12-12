defmodule Game2048Web.GameLive.FormComponent do
  use Game2048Web, :live_component

  alias Game2048.Games

  @impl true
  def update(%{new_game_form: new_game_form} = assigns, socket) do
    changeset = Games.change_new_game_form(new_game_form)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"new_game_form" => new_game_form_params}, socket) do
    changeset =
      socket.assigns.new_game_form
      |> Games.change_new_game_form(new_game_form_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"new_game_form" => new_game_form_params}, socket) do
    save_new_game_form(socket, socket.assigns.action, new_game_form_params)
  end

  defp save_new_game_form(socket, :new, new_game_form_params) do
    case Games.restart_game(new_game_form_params) do
      {:ok, _game} ->
        {:noreply,
         socket
         |> put_flash(:info, "A new game has started. Good luck!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
