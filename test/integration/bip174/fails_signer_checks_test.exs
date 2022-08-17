defmodule BitcoinLib.Test.Integration.Bip174.FailsSignerChecksTest do
  @moduledoc """
  These are from the fails signer checks section of this document https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#test-vectors
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Signing.Psbt

  test "Case: A Witness UTXO is provided for a non-witness input" do
    base_64 =
      "cHNidP8BAKACAAAAAqsJSaCMWvfEm4IS9Bfi8Vqz9cM9zxU4IagTn4d6W3vkAAAAAAD+////qwlJoIxa98SbghL0F+LxWrP1wz3PFTghqBOfh3pbe+QBAAAAAP7///8CYDvqCwAAAAAZdqkUdopAu9dAy+gdmI5x3ipNXHE5ax2IrI4kAAAAAAAAGXapFG9GILVT+glechue4O/p+gOcykWXiKwAAAAAAAEBItPf9QUAAAAAGXapFNSO0xELlAFMsRS9Mtb00GbcdCVriKwAAQEgAOH1BQAAAAAXqRQ1RebjO4MsRwUPJNPuuTycA5SLx4cBBBYAFIXRNTfy4mVAWjTbr6nj3aAfuCMIACICAurVlmh8qAYEPtw94RbN8p1eklfBls0FXPaYyNAr8k6ZELSmumcAAACAAAAAgAIAAIAAIgIDlPYr6d8ZlSxVh3aK63aYBhrSxKJciU9H2MFitNchPQUQtKa6ZwAAAIABAACAAgAAgAA="

    {:error, message} = base_64 |> Psbt.parse()

    assert "a witness UTXO contains a P2PKH script" == message
  end




  
end
