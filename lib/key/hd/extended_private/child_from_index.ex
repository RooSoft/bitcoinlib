defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndex do
  @moduledoc """
  Calculates direct childs from a private key based on a given index, and maybe a hardened flag
  """

  alias BitcoinLib.Key.HD.ExtendedPrivate

  @max_index 0x7FFFFFFF
  @hardened 0x80000000

  # this is n, as found here https://en.bitcoin.it/wiki/Secp256k1
  @order_of_the_curve 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141

  alias BitcoinLib.Key.HD.{Fingerprint, Hmac, ExtendedPrivate}

  @doc """
  Calculates a direct child from a private key based on a given index, and maybe a hardened flag

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>  key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
    ...>  chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndex.get(0)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPrivate{
        key: 0x39F329FEDBA2A68E2A804FCD9AEEA4104ACE9080212A52CE8B52C1FB89850C72,
        chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
        depth: 1,
        index: 0,
        parent_fingerprint: 0x18C1259
      }
    }
  """
  @spec get(%ExtendedPrivate{}, integer(), boolean()) ::
          {:ok, %ExtendedPrivate{}} | {:error, binary()}
  def get(private_key, index, hardened? \\ false)

  def get(_, index, _) when is_integer(index) and index > @max_index do
    {:error, "#{index} is too large of an index"}
  end

  def get(%ExtendedPrivate{} = private_key, index, hardened?) when is_integer(index) do
    index =
      case hardened? do
        true -> @hardened + index
        false -> index
      end

    %{child_private_key: child_private_key} =
      %{parent_private_key: private_key, index: index, hardened?: hardened?}
      |> compute_hmac
      |> compute_parent_fingerprint
      |> compute_child_private_key

    {:ok, child_private_key}
  end

  # hmac_left_part and hmac_right_part are Il and Ir in slip-0010 as found here
  # https://github.com/satoshilabs/slips/blob/master/slip-0010.md#master-key-generation
  defp compute_hmac(
         %{index: index, parent_private_key: parent_private_key, hardened?: hardened?} = hash
       ) do
    {derived_key, child_chain} = Hmac.compute(parent_private_key, index, hardened?)

    hash
    |> Map.put(:hmac_derived_key, derived_key)
    |> Map.put(:child_chain_code, child_chain)
  end

  defp compute_parent_fingerprint(%{parent_private_key: private_key} = hash) do
    hash
    |> Map.put(:parent_fingerprint, Fingerprint.compute(private_key))
  end

  defp compute_child_private_key(
         %{
           parent_private_key: parent_private_key,
           index: index,
           hmac_derived_key: hmac_derived_key,
           child_chain_code: child_chain_code,
           parent_fingerprint: parent_fingerprint
         } = hash
       ) do
    child_private_key =
      (hmac_derived_key + parent_private_key.key)
      |> rem(@order_of_the_curve)

    hash
    |> Map.put(:child_private_key, %ExtendedPrivate{
      key: child_private_key,
      chain_code: child_chain_code,
      depth: parent_private_key.depth + 1,
      index: index,
      parent_fingerprint: parent_fingerprint
    })
  end
end
