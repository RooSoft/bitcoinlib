defmodule BitcoinLib.Script.Value do
  @negative_zero 0x80

  def is_true?([]), do: false
  def is_true?(@negative_zero), do: false
  def is_true?(0), do: false
  def is_true?(_), do: true
end
