defmodule BitcoinLib.Key.Public do
  @moduledoc """
  Public key operations.
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Base58Check

  @type t :: binary

  @address_prefix [
    public: 0,
    script: 5,
    private: 128
  ]

  def from_private_key(private_key) do
    bitstring_private_key =
      private_key
      |> String.upcase()
      |> Base.decode16!()

    {public_uncompressed, _private} =
      :crypto.generate_key(:ecdh, :secp256k1, bitstring_private_key)

    compressed = get_compressed(public_uncompressed)

    {
      Base.encode16(public_uncompressed),
      Base.encode16(compressed)
    }
  end

  @doc """
  Check if public key is in either compressed or uncompressed format.

  Used for validation with the STRICTENC flag.
  """
  @spec strict?(t) :: boolean
  def strict?(pk) do
    cond do
      # Too short
      byte_size(pk) < 33 ->
        false

      # Invaild length for uncompressed key
      Binary.at(pk, 0) == 0x04 && byte_size(pk) != 65 ->
        false

      # Invalid length for compressed key
      Binary.at(pk, 0) in [0x02, 0x03] && byte_size(pk) != 33 ->
        false

      # Non-canonical: neither compressed nor uncompressed
      !(Binary.at(pk, 0) in [0x02, 0x03, 0x04]) ->
        false

      # Everything ok
      true ->
        true
    end
  end

  @doc """
  Convert public key into a Bitcoin address.

  Details can be found here: https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  """
  @spec to_address(t) :: binary
  def to_address(pk) do
    pk
    |> Crypto.sha256()
    |> Crypto.ripemd160()
    |> Binary.prepend(@address_prefix[:public])
    |> Base58Check.encode()
  end

  defp get_compressed(public_uncompressed) do
    first_char =
      public_uncompressed
      |> get_first_char

    compressed_body =
      public_uncompressed
      |> Binary.part(1, 32)

    first_char <> compressed_body
  end

  defp get_first_char(public_uncompressed) do
    reminder =
      public_uncompressed
      |> Binary.last()
      |> rem(2)

    case reminder do
      0 -> <<2>>
      1 -> <<3>>
    end
  end
end
