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
        key: 0x3D8E202D3D91B13E955D79BA88EADD709B98640D9633868C6274B9ACEED0F70EF,
        chain_code: 0x3159D0A560A856F5894C15EB0D657A74218B4979D8C6D76F8E78A42C83D22DA8,
        depth: 5,
        index: 0,
        parent_fingerprint: 0x3E4142F6,
        fingerprint: 0xD0D8EFE4
      }
    }
  """
  @spec get(%ExtendedPublic{}, %DerivationPath{}) :: {:ok, %ExtendedPublic{}}
  def get(%ExtendedPublic{} = public_key, %DerivationPath{} = derivation_path) do
    case derivation_path.type == :public do
      true -> derive(public_key, derivation_path)
      false -> {:error, "wrong derivation path type"}
    end
  end

  defp derive(%ExtendedPublic{} = public_key, %DerivationPath{} = derivation_path) do
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
        :bip49 -> ChildFromIndex.get(public_key, 49)
        :bip84 -> ChildFromIndex.get(public_key, 84)
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
