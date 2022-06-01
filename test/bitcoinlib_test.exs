defmodule BitcoinLib.Test do
  use ExUnit.Case

  test "generate a private key" do
    private_key = BitcoinLib.generate_private_key()

    assert is_bitstring(private_key)
    assert byte_size(private_key) == 32
  end
end
