defmodule BitcoinLib.Key.WifTest do
  use ExUnit.Case

  doctest BitcoinLib.Crypto.Wif

  alias BitcoinLib.Crypto.Wif

  test "creates a wif from an integer" do
    value =
      <<10, 141, 40, 107, 17, 185, 143, 108, 178, 88, 91, 98, 127, 244, 77, 18, 5, 149, 96, 172,
        212, 48, 220, 250, 18, 96, 239, 43, 217, 86, 147, 115>>

    wif = Wif.from_bitstring(value)

    assert wif == "KwaDo7PNi4XPMaABfSEo9rP6uviDUATAqvyjjWTcKp4fxdkVJWLe"
  end

  test "wif length should be 52" do
    value =
      <<10, 141, 40, 107, 17, 185, 143, 108, 178, 88, 91, 98, 127, 244, 77, 18, 5, 149, 96, 172,
        212, 48, 220, 250, 18, 96, 239, 43, 217, 86, 147, 115>>

    wif = Wif.from_bitstring(value)

    assert String.length(wif) == 52
  end

  test "creates a wif from the minimal integer" do
    value = <<1::256>>

    wif = Wif.from_bitstring(value)

    assert wif == "KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn"
  end
end
