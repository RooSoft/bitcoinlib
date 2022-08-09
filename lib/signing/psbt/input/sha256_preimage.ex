defmodule BitcoinLib.Signing.Psbt.Input.Sha256Preimage do
  defstruct [:hash, :value]

  alias BitcoinLib.Signing.Psbt.Input.Sha256Preimage
  alias BitcoinLib.Crypto

  def parse(<<preimage_hash::binary-size(32)>>, <<preimage::binary>>) do
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
