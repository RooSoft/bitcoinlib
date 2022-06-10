defmodule BitcoinLib.Key.HD.EncodingTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.Encoding

  alias BitcoinLib.Key.HD.Encoding

  test "encode a private master key" do
    private_key =
      <<48, 166, 181, 156, 204, 201, 36, 252, 159, 253, 74, 176, 140, 92, 1, 240, 214, 164, 4,
        103, 151, 187, 37, 93, 137, 25, 235, 62, 149, 192, 136, 113>>

    chain_code =
      <<6, 153, 124, 178, 70, 88, 112, 40, 104, 127, 225, 252, 192, 1, 218, 70, 31, 140, 14, 170,
        18, 208, 66, 25, 193, 177, 185, 173, 47, 200, 8, 241>>

    encoded = Encoding.encode_master(private_key, chain_code)

    assert encoded ==
             "xprv9s21ZrQH143K28Ahk9Y9brQrzj7eT37T638DpM9UrbADtnewHHHTAnyC92574dztZUFHgS44DeFbCmVFYQb6U8nDiX4jhANx6XL9CK8S84d"
  end
end
