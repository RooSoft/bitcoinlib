defmodule BitcoinLib.Block.Header do
  @moduledoc """
  Represents a Bitcoin block header

  Based on https://en.bitcoin.it/wiki/Block_hashing_algorithm
  """
  defstruct [:version, :previous_block_hash, :merkle_root_hash, :time, :bits, :nonce]

  alias BitcoinLib.Block.Header
  alias BitcoinLib.Crypto.Bitstring

  @doc """
  Converts a hex binary into a %Header{}

  ## Examples
      Parse the genesis block's header

      iex> "0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c"
      ...> |> Binary.from_hex()
      ...> |> BitcoinLib.Block.Header.parse()
      %BitcoinLib.Block.Header{
        version: 1,
        previous_block_hash: <<0::256>>,
        merkle_root_hash: <<0x4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b::256>>,
        time: ~U[2009-01-03 18:15:05Z],
        bits: 486604799,
        nonce: 2083236893
      }
  """
  @spec parse(<<_::640>>) :: {:ok, %Header{}} | {:error, binary()}
  def parse(<<
        version::little-32,
        previous_block_hash::bitstring-256,
        merkle_root_hash::bitstring-256,
        time::little-32,
        bits::little-32,
        nonce::little-32
      >>) do
    %Header{
      version: version,
      previous_block_hash: previous_block_hash |> Bitstring.reverse(),
      merkle_root_hash: merkle_root_hash |> Bitstring.reverse(),
      time: DateTime.from_unix!(time),
      bits: bits,
      nonce: nonce
    }
  end
end
