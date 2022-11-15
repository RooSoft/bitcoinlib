defmodule BitcoinLib.Block.HeaderTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Block.Header

  alias BitcoinLib.Block.Header

  test "try decoding an invalid block" do
    invalid_block_data = <<0>>

    {:error, message} = Header.decode(invalid_block_data)

    assert "invalid block" == message
  end
end
