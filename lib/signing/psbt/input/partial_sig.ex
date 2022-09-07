defmodule BitcoinLib.Signing.Psbt.Input.PartialSig do
  defstruct [:pub_key, :signature]

  @compressed_size 33
  @uncompressed_size 65

  alias BitcoinLib.Signing.Psbt.Input.PartialSig

  def parse(pub_key, signature) do
    %{pub_key: pub_key, signature: signature}
    |> validate_pub_key()
    |> create_partial_sig()
  end

  defp validate_pub_key(%{pub_key: pub_key} = map) do
    case byte_size(pub_key) do
      @compressed_size ->
        map

      @uncompressed_size ->
        map

      pub_key_size ->
        Map.put(map, :error, "wrong pub key size at #{pub_key_size}")
    end
  end

  defp create_partial_sig(%{error: _message} = map), do: map

  defp create_partial_sig(%{pub_key: pub_key, signature: signature} = map) do
    partial_sig = %PartialSig{
      pub_key: pub_key,
      signature: signature
    }

    map
    |> Map.put(partial_sig, partial_sig)
  end
end
