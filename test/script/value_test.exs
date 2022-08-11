defmodule BitcoinLib.Script.ValueTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Value

  alias BitcoinLib.Script.Value

  @negative_zero 0x80

  test "zero is false" do
    result = Value.is_true?(0)

    assert !result
  end

  test "negative zero is false" do
    result = Value.is_true?(@negative_zero)

    assert !result
  end

  test "empty array is false" do
    result = Value.is_true?([])

    assert !result
  end

  test "anything else is true" do
    result = Value.is_true?("a")

    assert result
  end
end
