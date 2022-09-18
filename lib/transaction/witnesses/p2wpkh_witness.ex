defmodule BitcoinLib.Transaction.Witnesses.P2wpkhWitness do
  @moduledoc """
  Witness section of a P2SH-P2WPKH transaction
  """

  alias BitcoinLib.Signing.Psbt.CompactInteger

  @witness_item_count 2
  @byte 8

  @doc """
  Encodes an witness into a bitstring

  ## Examples

    Based on https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki#p2sh-p2wpkh

    iex> signature = <<0x3044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb01::568>>
    ...> public_key = <<0x03ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a26873::264>>
    ...> BitcoinLib.Transaction.Witnesses.P2wpkhWitness.encode(signature, public_key)
    <<0x02473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb012103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a26873::856>>
  """
  @spec encode(bitstring(), bitstring()) :: bitstring()
  def encode(signature, public_key) do
    #  signature_bitstring = Binary.from_hex(signature)
    signature_size = byte_size(signature)
    encoded_signature_size = CompactInteger.encode(signature_size)

    # public_key_bitstring = Binary.from_hex(public_key)
    public_key_size = byte_size(public_key)
    encoded_public_key_size = CompactInteger.encode(public_key_size)

    <<
      @witness_item_count::@byte,
      encoded_signature_size::bitstring,
      signature::bitstring,
      encoded_public_key_size::bitstring,
      public_key::bitstring
    >>
  end
end
