defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct [:keypairs]

  @moduledoc """
    Extracts the global section of a PSBT from a binary according to the
    [specification](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#specification)

    <global-map> := <keypair>* 0x00
  """

  alias BitcoinLib.Signing.Psbt.{Global, Keypair}

  def from_data(data) do
    {remaining_data, keypairs} =
      data
      |> extract_keypairs()

    {%Global{keypairs: keypairs}, remaining_data}
  end

  defp extract_keypairs(data) do
    extract_keypairs(data, [])
  end

  defp extract_keypairs(<<0>>, keypairs), do: {<<>>, keypairs}
  defp extract_keypairs(<<0, remaining::binary>>, keypairs), do: {remaining, keypairs}

  defp extract_keypairs(data, keypairs) do
    {keypair, data} = extract_keypair(data)

    extract_keypairs(data, [keypair | keypairs])
  end

  defp extract_keypair(data) do
    data
    |> Keypair.extract_from()
  end
end
