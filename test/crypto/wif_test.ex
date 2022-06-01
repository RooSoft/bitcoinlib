defmodule BitcoinLib.Key.WifTest do
  use ExUnit.Case

  alias BitcoinLib.Crypto.Wif

  test "creates a wif from an integer" do
    value = 0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373

    wif = Wif.from_integer(value)

    assert wif == "KwaDo7PNi4XPMaABfSEo9rP6uviDUATAqvyjjWTcKp4fxdkVJWLe"
    assert String.length(wif) == 52
  end

  test "wif length should be 52" do
    value = 0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373

    wif = Wif.from_integer(value)

    assert String.length(wif) == 52
  end

  test "creates a wif from the minimal integer" do
    value = 1

    wif = Wif.from_integer(value)

    assert wif == "KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn"
  end
end
