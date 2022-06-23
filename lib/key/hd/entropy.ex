defmodule BitcoinLib.Key.HD.Entropy do
  @moduledoc """
  Computing entropy from different sources, mostly for mnemonic seed creation
  """

  @doc """
  Takes a list of dice rolls as a string argument, having values ranging from 0 to 5,
  transforming them into a single integer that could serve as entropy for mnemonic seed
  creation

  ## Examples
    iex> "01234501234501234501234501234501234501234501234501"
    ...> |> BitcoinLib.Key.HD.Entropy.from_dice_rolls()
    ...> |> elem(1)
    32_310_461_525_491_050_757_677_748_469_648_273_221
  """
  @spec from_dice_rolls(String.t()) :: {:ok, Integer.t()} | {:error, String.t()}
  def from_dice_rolls(dice_rolls) do
    dice_rolls
    |> validate_rolls
    |> maybe_parse_rolls
  end

  @doc """
  Takes a list of dice rolls as a string argument, having values ranging from 0 to 5,
  transforming them into a single integer that could serve as entropy for mnemonic seed
  creation

  ## Examples
    iex> "01234501234501234501234501234501234501234501234501"
    ...> |> BitcoinLib.Key.HD.Entropy.from_dice_rolls!()
    32_310_461_525_491_050_757_677_748_469_648_273_221
  """
  @spec from_dice_rolls!(String.t()) :: Integer.t()
  def from_dice_rolls!(dice_rolls) do
    from_dice_rolls(dice_rolls)
    |> elem(1)
  end

  defp validate_rolls(dice_rolls) do
    {
      Regex.match?(~r/^[0-5]+$/, dice_rolls),
      dice_rolls
    }
  end

  defp maybe_parse_rolls({true, dice_rolls}) do
    entropy =
      dice_rolls
      |> Integer.parse(6)
      |> elem(0)

    {:ok, entropy}
  end

  defp maybe_parse_rolls({false, _}) do
    {:error, "dice_rolls contains invalid characters outside of this range [0,5]"}
  end
end
