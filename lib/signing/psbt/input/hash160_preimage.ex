defmodule BitcoinLib.Signing.Psbt.Input.Hash160Preimage do
  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Hash160Preimage
  alias BitcoinLib.Crypto

  def parse(<<preimage_hash::bitstring-160>>, <<preimage::bitstring>>) do
    case validate(preimage_hash, preimage) do
      true ->
        %Hash160Preimage{
          hash: preimage_hash,
          value: preimage
        }

      false ->
        %{error: "HASH160 preimage hash not matching hash in key"}
    end
  end

  def parse(_) do
    %{error: "invalid HASH160 preimage"}
  end

  defp validate(hash, preimage) do
    hash ==
      preimage
      |> Crypto.hash160()
  end
end
