defmodule BitcoinLib.Signing.Psbt.Input.Sha256Preimage do
  @moduledoc """
  The SHA256 preimage of a partially signed bitcoin transaction's input
  """

  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Sha256Preimage
  alias BitcoinLib.Crypto

  # TODO: document
  def parse(<<preimage_hash::bitstring-256>>, <<preimage::bitstring>>) do
    case validate(preimage_hash, preimage) do
      true ->
        %Sha256Preimage{
          hash: preimage_hash,
          value: preimage
        }

      false ->
        %{error: "SHA256 preimage hash not matching hash in key"}
    end
  end

  def parse(_) do
    %{error: "invalid SHA256 preimage"}
  end

  defp validate(hash, preimage) do
    hash ==
      preimage
      |> Crypto.sha256()
  end
end
