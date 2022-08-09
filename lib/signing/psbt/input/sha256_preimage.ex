defmodule BitcoinLib.Signing.Psbt.Input.Sha256Preimage do
  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Sha256Preimage

  def parse(<<preimage_hash::binary-size(32)>>, <<preimage::binary>>) do
    %Sha256Preimage{
      hash: preimage_hash,
      value: preimage
    }
  end

  def parse(_) do
    %{error: "invalid SHA256 preimage"}
  end
end
