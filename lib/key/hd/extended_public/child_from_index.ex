defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex do
  alias BitcoinLib.Key.HD.ExtendedPublic

  @max_index 0x7FFFFFFF

  alias BitcoinLib.Key.HD.{Fingerprint, Hmac, ExtendedPublic}

  @spec get(%ExtendedPublic{}, Integer.t()) ::
          {:ok, %ExtendedPublic{}} | {:error, String.t()}
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
    hash
    |> Map.put(:child_public_key, %ExtendedPublic{
      key: hmac_derived_key + parent_public_key.key,
      chain_code: child_chain_code,
      depth: parent_public_key.depth + 1,
      index: index,
      parent_fingerprint: parent_fingerprint
    })
  end
end
