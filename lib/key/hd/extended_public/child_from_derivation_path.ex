defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromDerivationPath do
  @moduledoc """
  Computes a public key from a derivation path
  """

  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPublic}
  alias BitcoinLib.Key.HD.DerivationPath.{Level}
  alias BitcoinLib.Key.HD.ExtendedPublic.{ChildFromIndex}

  @doc """
  Computes a public key from a derivation path

  ## Examples
    iex> { :ok, derivation_path } = BitcoinLib.Key.HD.DerivationPath.parse("M/84'/0'/0'/0/0")
    ...> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>  key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
    ...>  chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.ChildFromDerivationPath.get(derivation_path)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPublic{
        key: 0x2760726D27F441E32069B8922DB70DCA135A583BC186A1B9568104316A97F6F8C,
        chain_code: 0xD42BD3A1611DF60BE3C23EF0777EFEB4EBB50BAC69C40196471F06EBC7084E8A,
        depth: 4,
        index: 0,
        parent_fingerprint: 0xF803B513
        }
      }
  """
  @spec get(%ExtendedPublic{}, %DerivationPath{}) :: {:ok, %ExtendedPublic{}}
  def get(%ExtendedPublic{} = public_key, %DerivationPath{} = derivation_path) do
    {child_public_key, _} =
      {public_key, derivation_path}
      |> maybe_derive_purpose
      |> maybe_derive_coin_type
      |> maybe_derive_account
      |> maybe_derive_change
      |> maybe_derive_address_index

    {:ok, child_public_key}
  end

  defp maybe_derive_purpose({%ExtendedPublic{}, %DerivationPath{purpose: nil}} = hash) do
    hash
  end

  defp maybe_derive_purpose(
         {%ExtendedPublic{} = public_key, %DerivationPath{purpose: purpose} = derivation_path}
       ) do
    {:ok, child_public_key} =
      case purpose do
        :bip44 -> ChildFromIndex.get(public_key, 44)
        _ -> {:ok, public_key}
      end

    {child_public_key, derivation_path}
  end

  defp maybe_derive_coin_type({%ExtendedPublic{}, %DerivationPath{coin_type: nil}} = hash) do
    hash
  end

  defp maybe_derive_coin_type(
         {%ExtendedPublic{} = public_key, %DerivationPath{coin_type: coin_type} = derivation_path}
       ) do
    {:ok, child_public_key} =
      case coin_type do
        :bitcoin -> ChildFromIndex.get(public_key, 0)
        :bitcoin_testnet -> ChildFromIndex.get(public_key, 1)
        _ -> {:ok, public_key}
      end

    {child_public_key, derivation_path}
  end

  defp maybe_derive_account({%ExtendedPublic{}, %DerivationPath{account: nil}} = hash) do
    hash
  end

  defp maybe_derive_account(
         {public_key, %DerivationPath{account: %Level{value: account}} = derivation_path}
       ) do
    {:ok, child_public_key} = ChildFromIndex.get(public_key, account)

    {child_public_key, derivation_path}
  end

  defp maybe_derive_change({%ExtendedPublic{}, %DerivationPath{change: nil}} = hash) do
    hash
  end

  defp maybe_derive_change(
         {%ExtendedPublic{} = public_key, %DerivationPath{change: change} = derivation_path}
       ) do
    {:ok, child_public_key} =
      case change do
        :receiving_chain -> ChildFromIndex.get(public_key, 0)
        :change_chain -> ChildFromIndex.get(public_key, 1)
        _ -> {:ok, public_key}
      end

    {child_public_key, derivation_path}
  end

  defp maybe_derive_address_index({%ExtendedPublic{}, %DerivationPath{address_index: nil}} = hash) do
    hash
  end

  defp maybe_derive_address_index(
         {%ExtendedPublic{} = public_key,
          %DerivationPath{address_index: %Level{value: index}} = derivation_path}
       ) do
    {:ok, child_public_key} = ChildFromIndex.get(public_key, index)

    {child_public_key, derivation_path}
  end
end
