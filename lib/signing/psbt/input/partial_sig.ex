defmodule BitcoinLib.Signing.Psbt.Input.PartialSig do
  defstruct [:pub_key, :signature]

  alias BitcoinLib.Signing.Psbt.Input.PartialSig

  def parse(pub_key, signature) do
    %PartialSig{
      pub_key: Binary.to_hex(pub_key),
      signature: Binary.to_hex(signature)
    }
  end
end
