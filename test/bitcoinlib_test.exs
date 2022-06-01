defmodule BitcoinLib.Test do
  use ExUnit.Case

  test "generate a private key: raw version" do
    %{raw: private_key} = BitcoinLib.generate_private_key()

    assert is_integer(private_key)
  end

  test "generate a private key: wif version" do
    %{wif: private_key} = BitcoinLib.generate_private_key()

    assert is_binary(private_key)
    assert byte_size(private_key) == 52
  end

  # test "public key derivation from a private key" do
  #   private_key =
  #     <<189, 95, 7, 16, 129, 49, 152, 91, 12, 2, 172, 172, 1, 37, 219, 223, 174, 232, 13, 196,
  #       196, 117, 255, 172, 182, 94, 51, 46, 48, 207, 238, 36>>

  #   public_key = BitcoinLib.derive_public_key()

  #   assert true
  # end
end
