defmodule BitcoinLib.Key.HD.Entropy do
  @moduledoc """
  Computing entropy from different sources, mostly for seed phrase creation
  """

  @doc """
  Takes a list of dice rolls as a string argument, having values ranging from 0 to 5,
  transforming them into a single integer that could serve as entropy for seed phrase
  creation

  ## Examples
    iex> "12345612345612345612345612345612345612345612345612"
    ...> |> BitcoinLib.Key.HD.Entropy.from_dice_rolls()
    ...> |> elem(1)
    32_310_461_525_491_050_757_677_748_469_648_273_221
  """
  @spec from_dice_rolls(binary()) :: {:ok, integer()} | {:error, binary()}
  def from_dice_rolls(dice_rolls) do
    dice_rolls
    |> validate_rolls
    |> maybe_decrement_rolls
    |> maybe_parse_rolls
  end

  @doc """
  Takes a list of dice rolls as a string argument, having values ranging from 0 to 5,
  transforming them into a single integer that could serve as entropy for seed phrase
  creation

  ## Examples
    iex> "12345612345612345612345612345612345612345612345612"
    ...> |> BitcoinLib.Key.HD.Entropy.from_dice_rolls!()
    32_310_461_525_491_050_757_677_748_469_648_273_221
  """
  @spec from_dice_rolls!(binary()) :: integer()
  def from_dice_rolls!(dice_rolls) do
    from_dice_rolls(dice_rolls)
    |> elem(1)
  end

  defp validate_rolls(dice_rolls) do
    case String.length(dice_rolls) do
      n when n in [50, 99] ->
        validate_dices(dice_rolls)

      number_of_rolls ->
        {:error,
         "Please provide 50 dice rolls for 12 words or 99 dice rolls for 24 words, got #{number_of_rolls}"}
    end
  end

  defp validate_dices(dice_rolls) do
    case Regex.match?(~r/^[1-6]+$/, dice_rolls) do
      true -> {:ok, dice_rolls}
      false -> {:error, "Please provide characters inside the [1,6] range, got #{dice_rolls}"}
    end
  end

  defp maybe_decrement_rolls({:ok, dice_rolls}) do
    zero_based_dice_rolls =
      <<i::8 <- dice_rolls>>
      |> for(do: <<i - 1>>)
      |> Enum.join()

    {:ok, zero_based_dice_rolls}
  end

  defp maybe_decrement_rolls(input), do: input

  defp maybe_parse_rolls({:ok, dice_rolls}) do
    entropy =
      dice_rolls
      |> Integer.parse(6)
      |> elem(0)

    {:ok, entropy}
  end

  defp maybe_parse_rolls(input), do: input
end
