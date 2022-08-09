defmodule BitcoinLib.Signing.Psbt.Input.Ripemd160Preimage do
  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Ripemd160Preimage

  def parse(<<preimage_hash::binary-size(20)>>, <<preimage::binary>>) do
    %Ripemd160Preimage{
      hash: preimage_hash,
      value: preimage
    }
  end

  def parse(_) do
    %{error: "invalid RIPEMD160 preimage"}
  end
end
