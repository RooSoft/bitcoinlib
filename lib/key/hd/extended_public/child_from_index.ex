defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex do
  @moduledoc """
  Calculates direct childs from a public key based on a given index
  """

  alias BitcoinLib.Key.HD.ExtendedPublic

  @max_index 0x7FFFFFFF

  alias BitcoinLib.Key.HD.{Fingerprint, Hmac, ExtendedPublic}
  alias BitcoinLib.Crypto.Secp256k1

  @doc """
  Calculates a direct child from a public key based on a given index

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
    ...>   chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex.get(0)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPublic{
        fingerprint: 0x9680603F,
        key: 0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59,
        chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
        depth: 1,
        index: 0,
        parent_fingerprint: 0x18C1259
      }
    }
  """
  @spec get(%ExtendedPublic{}, integer()) ::
          {:ok, %ExtendedPublic{}} | {:error, binary()}
  def get(_parent_public_key, index) when is_integer(index) and index > @max_index do
    {:error, "#{index} is too large of an index"}
  end

  def get(%ExtendedPublic{} = parent_public_key, index) when is_integer(index) do
    %{child_public_key: child_public_key} =
      %{parent_public_key: parent_public_key, index: index}
      |> compute_hmac
      |> compute_parent_fingerprint
      |> compute_child_public_key

    {:ok, child_public_key}
  end

  # hmac_left_part and hmac_right_part are Il and Ir in slip-0010 as found here
  # https://github.com/satoshilabs/slips/blob/master/slip-0010.md#master-key-generation
  defp compute_hmac(
         %{
           index: index,
           parent_public_key: %ExtendedPublic{} = parent_public_key
         } = hash
       ) do
    {derived_key, child_chain} = Hmac.compute(parent_public_key, index)

    hash
    |> Map.put(:hmac_derived_key, derived_key)
    |> Map.put(:child_chain_code, child_chain)
  end

  defp compute_parent_fingerprint(%{parent_public_key: parent_public_key} = hash) do
    hash
    |> Map.put(:parent_fingerprint, Fingerprint.compute(parent_public_key))
  end

  defp compute_child_public_key(
         %{
           parent_public_key: parent_public_key,
           index: index,
           hmac_derived_key: hmac_derived_key,
           child_chain_code: child_chain_code,
           parent_fingerprint: parent_fingerprint
         } = hash
       ) do
    {_, key} =
      hmac_derived_key
      |> BitcoinLib.Key.Public.from_private_key()

    child_public_key =
      %ExtendedPublic{
        key: Secp256k1.add_keys(key, parent_public_key.key),
        chain_code: child_chain_code,
        depth: parent_public_key.depth + 1,
        index: index,
        parent_fingerprint: parent_fingerprint
      }
      |> Fingerprint.append()

    hash
    |> Map.put(:child_public_key, child_public_key)
  end
end
