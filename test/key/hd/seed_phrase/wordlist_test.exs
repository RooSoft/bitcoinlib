defmodule BitcoinLib.Key.HD.SeedPhrase.WordlistTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.SeedPhrase.Wordlist

  alias BitcoinLib.Key.HD.SeedPhrase.Wordlist

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

  test "get word indice" do
    indice = Wordlist.get_indice("absurd")

    assert {:found, 8, "absurd"} == indice
  end

  test "convert a list of words into indices" do
    words = Wordlist.get_indices(["absurd", "able", "absent"])

    assert [8, 2, 5] == words
  end
end
