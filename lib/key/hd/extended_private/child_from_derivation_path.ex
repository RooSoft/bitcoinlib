defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromDerivationPath do
  @moduledoc """
  Computes a private key from a derivation path
  """

  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPrivate}
  alias BitcoinLib.Key.HD.DerivationPath.{Level}
  alias BitcoinLib.Key.HD.ExtendedPrivate.{ChildFromIndex}

  @doc """
  Computes a private key from a derivation path

  ## Examples
    iex> { :ok, derivation_path } = BitcoinLib.Key.HD.DerivationPath.parse("m/84'/0'/0'/0/0")
    ...> %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>  key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
    ...>  chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.ChildFromDerivationPath.get(derivation_path)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPrivate{
        key: 0xF884F5D6A4CB4F2F859FBE1FE75DFE5A48822FD56A59A0B375FC0BAF8CC5C84E,
        chain_code: 0xB0B26A820035421BD94DAE603F7354C275EDF007A4086BDD67B327301D852EBE,
        depth: 4,
        index: 0,
        parent_fingerprint: 0x7C33408C
        }
      }
  """
  @spec get(%ExtendedPrivate{}, %DerivationPath{}) :: {:ok, %ExtendedPrivate{}}
  def get(%ExtendedPrivate{} = private_key, %DerivationPath{} = derivation_path) do
    {child_private_key, _} =
      {private_key, derivation_path}
      |> maybe_derive_purpose
      |> maybe_derive_coin_type
      |> maybe_derive_account
      |> maybe_derive_change
      |> maybe_derive_address_index

    {:ok, child_private_key}
  end

  defp maybe_derive_purpose({%ExtendedPrivate{}, %DerivationPath{purpose: nil}} = hash) do
    hash
  end

  defp maybe_derive_purpose(
         {%ExtendedPrivate{} = private_key, %DerivationPath{purpose: purpose} = derivation_path}
       ) do
    {:ok, child_private_key} =
      case purpose do
        :bip44 -> ChildFromIndex.get(private_key, 44, true)
        _ -> {:ok, private_key}
      end

    {child_private_key, derivation_path}
  end

  defp maybe_derive_coin_type({%ExtendedPrivate{}, %DerivationPath{coin_type: nil}} = hash) do
    hash
  end

  defp maybe_derive_coin_type(
         {%ExtendedPrivate{} = private_key,
          %DerivationPath{coin_type: coin_type} = derivation_path}
       ) do
    {:ok, child_private_key} =
      case coin_type do
        :bitcoin -> ChildFromIndex.get(private_key, 0, true)
        :bitcoin_testnet -> ChildFromIndex.get(private_key, 1, true)
        _ -> {:ok, private_key}
      end

    {child_private_key, derivation_path}
  end

  defp maybe_derive_account({%ExtendedPrivate{}, %DerivationPath{account: nil}} = hash) do
    hash
  end

  defp maybe_derive_account(
         {private_key,
          %DerivationPath{account: %Level{hardened?: true, value: account}} = derivation_path}
       ) do
    {:ok, child_private_key} = ChildFromIndex.get(private_key, account, true)

    {child_private_key, derivation_path}
  end

  defp maybe_derive_change({private_key, %DerivationPath{change: nil} = derivation_path}) do
    {private_key, derivation_path}
  end

  defp maybe_derive_change({private_key, %DerivationPath{change: change} = derivation_path}) do
    {:ok, child_private_key} =
      case change do
        :receiving_chain -> ChildFromIndex.get(private_key, 0, false)
        :change_chain -> ChildFromIndex.get(private_key, 1, false)
        _ -> {:ok, private_key}
      end

    {child_private_key, derivation_path}
  end

  defp maybe_derive_address_index(
         {private_key, %DerivationPath{address_index: nil} = derivation_path}
       ) do
    {private_key, derivation_path}
  end

  defp maybe_derive_address_index(
         {private_key,
          %DerivationPath{address_index: %Level{hardened?: hardened?, value: index}} =
            derivation_path}
       ) do
    {:ok, child_private_key} = ChildFromIndex.get(private_key, index, hardened?)

    {child_private_key, derivation_path}
  end
end
