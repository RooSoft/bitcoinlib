defmodule BitcoinLib.Signing.Psbt.Input.Hash160Preimage do
  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Hash160Preimage

  def parse(<<preimage_hash::binary-size(20)>>, <<preimage::binary>>) do
    %Hash160Preimage{
      hash: preimage_hash,
      value: preimage
    }
  end

  def parse(_) do
    %{error: "invalid HASH160 preimage"}
  end
end
