defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromDerivationPath do
  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPrivate}
  alias BitcoinLib.Key.HD.DerivationPath.{Level}
  alias BitcoinLib.Key.HD.ExtendedPrivate.{ChildFromIndex}

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

  defp maybe_derive_purpose(
         {%ExtendedPrivate{} = private_key, %DerivationPath{purpose: nil} = derivation_path}
       ) do
    {private_key, derivation_path}
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

  defp maybe_derive_coin_type(
         {%ExtendedPrivate{} = private_key, %DerivationPath{coin_type: nil} = derivation_path}
       ) do
    {private_key, derivation_path}
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

  defp maybe_derive_account({private_key, %DerivationPath{account: nil} = derivation_path}) do
    {private_key, derivation_path}
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
