defmodule NytgamesWeb.Wordle do
  alias Nytgames.WordleGuess
  use NytgamesWeb, :live_view

  @words File.read!("words.txt") |> String.split()

  @impl true
  def mount(_params, _session, socket) do
    word = Enum.random(@words)

    socket =
      socket
      |> assign(:word, word)
      |> assign(:guesses, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("guess", %{"guess" => guess}, socket) do
    guesses = socket.assigns.guesses
    guess = guess |> String.downcase()

    if Enum.any?(guesses, &(&1.guess === guess)) || String.length(guess) !== 5 do
      {:noreply, socket}
    else
      {:noreply,
       assign(
         socket,
         :guesses,
         guesses ++ [WordleGuess.make_guess(guess, socket.assigns.word)]
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-6xl">Wordle</h1>

    <.word :for={guess <- @guesses} guess={guess} />

    <form :if={Enum.all?(@guesses, &(&1.guess !== @word)) && length(@guesses) < 6} phx-submit="guess">
      <input type="text" name="guess" phx-hook="Focus" id="guess" />
      <button type="submit">Guess</button>
    </form>

    <h2 :if={Enum.any?(@guesses, &(&1.guess === @word))} class="text-2xl">Winner!</h2>
    <h2 :if={length(@guesses) === 6 && Enum.all?(@guesses, &(&1.guess !== @word))} class="text-2xl">
      Maybe next time! Word was: <%= @word %>
    </h2>

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
