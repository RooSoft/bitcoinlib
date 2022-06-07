defmodule BitcoinLib.Key.MnemonicSeed.WordlistTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.MnemonicSeed.Wordlist

  alias BitcoinLib.Key.MnemonicSeed.Wordlist

  test "get allwords" do
    wordlist = Wordlist.all()

    assert 2048 == Enum.count(wordlist)
  end

  test "get word number 8" do
    word = Wordlist.get(8)

    assert "absurd" == word
  end
end
