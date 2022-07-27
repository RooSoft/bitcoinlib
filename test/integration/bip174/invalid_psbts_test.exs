defmodule BitcoinLib.Test.Integration.Bip174.InvalidPsbtsTest do
  @moduledoc """
  These are from the invalid PSBT section of this document https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#test-vectors
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Signing.Psbt

  test "Case: Network transaction, not PSBT format" do
    base_64 =
      "AgAAAAEmgXE3Ht/yhek3re6ks3t4AAwFZsuzrWRkFxPKQhcb9gAAAABqRzBEAiBwsiRRI+a/R01gxbUMBD1MaRpdJDXwmjSnZiqdwlF5CgIgATKcqdrPKAvfMHQOwDkEIkIsgctFg5RXrrdvwS7dlbMBIQJlfRGNM1e44PTCzUbbezn22cONmnCry5st5dyNv+TOMf7///8C09/1BQAAAAAZdqkU0MWZA8W6woaHYOkP1SGkZlqnZSCIrADh9QUAAAAAF6kUNUXm4zuDLEcFDyTT7rk8nAOUi8eHsy4TAA=="

    {:error, message} = base_64 |> Psbt.parse()

    assert "magic bytes missing" == message
  end
end
