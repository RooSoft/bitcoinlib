defmodule BitcoinLib.Signing.Psbt.Input.Hash256Preimage do
  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Hash256Preimage

  def parse(<<preimage_hash::binary-size(20)>>, <<preimage::binary>>) do
    %Hash256Preimage{
      hash: preimage_hash,
      value: preimage
    }
  end

  def parse(_) do
    %{error: "invalid HASH256 preimage"}
  end
end
