defmodule BitcoinLib.Signing.Psbt.Input.Hash256Preimage do
  @moduledoc """
  The double SHA256 of a partially signed bitcoin transaction's input preimage
  """

  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Hash256Preimage
  alias BitcoinLib.Crypto

  # TODO: document
  def parse(<<preimage_hash::bitstring-256>>, <<preimage::bitstring>>) do
    case validate(preimage_hash, preimage) do
      true ->
        %Hash256Preimage{
          hash: preimage_hash,
          value: preimage
        }

      false ->
        %{error: "HASH256 preimage hash not matching hash in key"}
    end
  end

  def parse(_) do
    %{error: "invalid HASH256 preimage"}
  end

  defp validate(hash, preimage) do
    hash ==
      preimage
      |> Crypto.double_sha256()
  end
end
