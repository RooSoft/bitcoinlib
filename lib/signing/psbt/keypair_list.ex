defmodule BitcoinLib.Signing.Psbt.KeypairList do
  defstruct keypairs: []

  @moduledoc """
    Extracts a Keypair list from from a binary according to the
    [specification](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#specification)

    <global-map> := <keypair>* 0x00
    <input-map> := <keypair>* 0x00
    <output-map> := <keypair>* 0x00
  """

  alias BitcoinLib.Signing.Psbt.{KeypairList, Keypair}

  # TODO: document
  def from_data(data) do
    {remaining_data, keypairs} =
      data
      |> extract_keypairs()

    case keypairs do
      [] -> {nil, remaining_data}
      _ -> {%KeypairList{keypairs: keypairs}, remaining_data}
    end
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
