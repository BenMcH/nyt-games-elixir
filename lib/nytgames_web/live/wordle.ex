defmodule NytgamesWeb.Wordle do
  alias Nytgames.WordleGuess
  use NytgamesWeb, :live_view

  @words File.read!("words.txt") |> String.split()

  defp new_game(socket) do
    word = Enum.random(@words)

    socket
    |> assign(:word, word)
    |> assign(:status, :playing)
    |> assign(:guesses, [])
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> new_game()}
  end

  @impl true
  def handle_event("new_game", _, socket) do
    {:noreply, socket |> new_game()}
  end

  @impl true
  def handle_event("guess", %{"guess" => guess}, socket) do
    guesses = socket.assigns.guesses
    guess = guess |> String.downcase()

    if Enum.any?(guesses, &(&1.guess === guess)) || String.length(guess) !== 5 do
      {:noreply, socket}
    else
      status =
        cond do
          guess === socket.assigns.word -> :winner
          length(guesses) === 5 -> :loser
          true -> :playing
        end

      socket =
        socket
        |> assign(:status, status)
        |> assign(:guesses, guesses ++ [WordleGuess.make_guess(guess, socket.assigns.word)])

      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-6xl">Wordle</h1>

    <.word :for={guess <- @guesses} guess={guess} />

    <form :if={@status === :playing} phx-submit="guess">
      <input type="text" name="guess" phx-hook="Focus" id="guess" minlength="5" maxlength="5" />
      <button type="submit">Guess</button>
    </form>

    <h2 :if={@status === :winner} class="text-2xl">Winner!</h2>
    <h2 :if={@status === :loser} class="text-2xl">
      Maybe next time! Word was: <%= @word %>
    </h2>
    <div :if={@status !== :playing}><button phx-click="new_game">Try again</button></div>

    <h2 class="text-xl">Guesses: <%= length(@guesses) %>/6</h2>
    """
  end

  def word(assigns) do
    ~H"""
    <div class="flex flex-row gap-2 mb-2">
      <span
        :for={{point, index} <- @guess.guess |> String.codepoints() |> Enum.with_index()}
        class={[
          "flex-1",
          "aspect-square",
          "flex",
          "items-center",
          "justify-center",
          "border-2",
          "border-black",
          "text-white",
          "font-bold",
          "text-3xl",
          Enum.at(@guess.colors, index)
        ]}
      >
        <%= point %>
      </span>
    </div>
    """
  end
end
