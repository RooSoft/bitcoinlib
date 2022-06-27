defmodule BitcoinLib.Key.HD.Fingerprint do
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPublic, ExtendedPrivate}

  def compute(%ExtendedPrivate{} = private_key) do
    private_key
    |> to_public_key
    |> compute
  end

  def compute(%ExtendedPublic{} = public_key) do
    <<raw_fingerprint::binary-4, _rest::binary>> =
      public_key.key
      |> Binary.from_integer()
      |> Crypto.hash160_bitstring()

    raw_fingerprint
    |> Binary.to_integer()
  end

  defp to_public_key(%ExtendedPrivate{} = private_key) do
    private_key
    |> ExtendedPublic.from_private_key()
  end
end
