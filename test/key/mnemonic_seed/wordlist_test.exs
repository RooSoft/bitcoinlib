defmodule BitcoinLib.Key.MnemonicSeed.WordlistTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.MnemonicSeed.Wordlist

  alias BitcoinLib.Key.MnemonicSeed.Wordlist

  test "get allwords" do
    wordlist = Wordlist.all()

    assert 2048 == Enum.count(wordlist)
  end

  test "get word number 8" do
    word = Wordlist.get_word(8)

    assert "absurd" == word
  end

  test "convert a list of indices into words" do
    words = Wordlist.get_words([8, 2, 5])

    assert ["absurd", "able", "absent"] == words
  end
end
