defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndex do
  alias BitcoinLib.Key.HD.ExtendedPrivate

  @max_index 0x7FFFFFFF
  @hardened 0x80000000

  # this is n, as found here https://en.bitcoin.it/wiki/Secp256k1
  @order_of_the_curve 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141

  alias BitcoinLib.Key.HD.{Fingerprint, Hmac, ExtendedPrivate}

  @spec get(%ExtendedPrivate{}, Integer.t(), Integer.t()) ::
          {:ok, %ExtendedPrivate{}} | {:error, String.t()}
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
    |> Map.put(:derived_key, derived_key)
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
           derived_key: derived_key,
           child_chain_code: child_chain_code,
           parent_fingerprint: parent_fingerprint
         } = hash
       ) do
    child_private_key =
      (derived_key + parent_private_key.key)
      |> rem(@order_of_the_curve)

    hash
    |> Map.put(:child_private_key, %ExtendedPrivate{
      key: child_private_key,
      chain_code: child_chain_code |> Binary.to_integer(),
      depth: parent_private_key.depth + 1,
      index: index,
      parent_fingerprint: parent_fingerprint
    })
  end
end
