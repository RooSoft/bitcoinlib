defmodule BitcoinLib.Test.Integration.Bip32.SeedToSerializedPrivateKeysTest do
  @moduledoc """
  Values from here: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1
  """

  use ExUnit.Case, async: true

  test "create a private key from a specific seed and output the xprv string" do
    seed = "000102030405060708090a0b0c0d0e0f"

    serialized = create_serialized_private_key(seed)

    assert "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi" ==
             serialized
  end

  defp create_serialized_private_key(seed) do
    %{key: key, chain_code: chain_code} =
      seed
      |> BitcoinLib.Key.HD.ExtendedPrivate.from_seed()

    BitcoinLib.Key.HD.ExtendedPrivate.serialize_master_key(key, chain_code)
  end
end
