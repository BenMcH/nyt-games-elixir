defmodule Nytgames.WordleGuess do
  alias Nytgames.WordleGuess
  @enforce_keys [:guess, :colors]
  defstruct [:guess, :colors]

  def make_guess(guess, target) do
    colors = get_colors(guess, target)

    %WordleGuess{guess: guess, colors: colors}
  end

  defp get_colors(guess, target) do
    letters = guess |> String.codepoints()
    target_letters = target |> String.codepoints()

    {letters, target_letters} = do_greens(letters, target_letters)

    letters
    |> do_yellows(target_letters)
    |> Enum.map(fn letter ->
      cond do
        letter === :green -> "bg-green-700"
        letter === :yellow -> "bg-yellow-500"
        true -> "bg-slate-700"
      end
    end)
  end

  defp do_greens(letters, target_letters) do
    Enum.zip(letters, target_letters)
    |> Enum.reduce({[], []}, fn {letter, target}, {acc_letter, acc_target} ->
      if letter === target do
        {acc_letter ++ [:green], acc_target}
      else
        {acc_letter ++ [letter], acc_target ++ [target]}
      end
    end)
  end

  defp do_yellows(letters, targets, acc \\ [])

  defp do_yellows(letters, targets, acc) when targets === [] or letters === [],
    do: acc ++ letters

  defp do_yellows([letter | tail], targets, acc) do
    if letter in targets do
      do_yellows(tail, targets -- [letter], acc ++ [:yellow])
    else
      do_yellows(tail, targets, acc ++ [letter])
    end
  end
end
