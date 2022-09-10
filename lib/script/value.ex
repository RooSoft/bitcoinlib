defmodule BitcoinLib.Script.Value do
  @moduledoc """
  Truthness evaluator for script execution outcomes
  """

  @negative_zero 0x80

  @doc """
  Returns true if the value passed to it is considered as such

  ## Examples
    iex> BitcoinLib.Script.Value.is_true?(1)
    true
  """
  @spec is_true?(list() | integer() | any()) :: boolean()
  def is_true?([]), do: false
  def is_true?(@negative_zero), do: false
  def is_true?(0), do: false
  def is_true?(_), do: true
end
