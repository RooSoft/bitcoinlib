defmodule BitcoinLib.Signing.Psbt.Input.PartialSig do
  defstruct [:pub_key, :signature]

  @compressed_size 33
  @uncompressed_size 65

  alias BitcoinLib.Signing.Psbt.Input.PartialSig

  def parse(pub_key, signature) do
    {pub_key, signature, %PartialSig{}}
    |> validate_pub_key()
    |> create_partial_sig()
  end

  defp validate_pub_key({pub_key, signature, partial_sig} = map) do
    case byte_size(pub_key) do
      @compressed_size ->
        map

      @uncompressed_size ->
        map

      pub_key_size ->
        {pub_key, signature,
         Map.put(partial_sig, :error, "wrong pub key size at #{pub_key_size}")}
    end
  end

  defp create_partial_sig({pub_key, signature, %{error: nil}}) do
    partial_sig = %PartialSig{
      pub_key: pub_key,
      signature: signature
    }

    {pub_key, signature, partial_sig}
  end

  defp create_partial_sig({_, _, partial_sig}), do: partial_sig
end
