defmodule BitcoinLib.Key.PrivateKey.ChildFromDerivationPath do
  @moduledoc """
  Computes a private key from a derivation path
  """

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Key.HD.{DerivationPath}
  alias BitcoinLib.Key.HD.DerivationPath.{Level}
  alias BitcoinLib.Key.PrivateKey.{ChildFromIndex}

  @doc """
  Computes a private key from a derivation path

  ## Examples
      iex> { :ok, derivation_path } = BitcoinLib.Key.HD.DerivationPath.parse("m/84'/0'/0'/0/0")
      ...> %BitcoinLib.Key.PrivateKey{
      ...>  key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      ...>  chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
      ...> }
      ...> |> BitcoinLib.Key.PrivateKey.ChildFromDerivationPath.get(derivation_path)
      {
        :ok,
        %BitcoinLib.Key.PrivateKey{
          key: <<0x210DDF6EA57B57C4607B17F9774C3F48AC92DA3AE5FF03D215CCE56AA021DAA6::256>>,
          chain_code: <<0x143B6DAC88591B42BD7D74AA193D4EFC7826873B4BD5F491B7067E705B8A626E::256>>,
          depth: 5,
          index: 0,
          parent_fingerprint: <<0xFFF4D449::32>>
        }
      }
  """
  @spec get(%PrivateKey{}, %DerivationPath{}) :: {:ok, %PrivateKey{}}
  def get(%PrivateKey{} = private_key, %DerivationPath{} = derivation_path) do
    case derivation_path.type == :private do
      true -> derive(private_key, derivation_path)
      false -> {:error, "wrong derivation path type"}
    end
  end

  defp derive(%PrivateKey{} = private_key, %DerivationPath{} = derivation_path) do
    {child_private_key, _} =
      {private_key, derivation_path}
      |> maybe_derive_purpose
      |> maybe_derive_coin_type
      |> maybe_derive_account
      |> maybe_derive_change
      |> maybe_derive_address_index

    {:ok, child_private_key}
  end

  defp maybe_derive_purpose({%PrivateKey{}, %DerivationPath{purpose: nil}} = hash) do
    hash
  end

  defp maybe_derive_purpose(
         {%PrivateKey{} = private_key, %DerivationPath{purpose: purpose} = derivation_path}
       ) do
    {:ok, child_private_key} =
      case purpose do
        :bip44 -> ChildFromIndex.get(private_key, 44, true)
        :bip49 -> ChildFromIndex.get(private_key, 49, true)
        :bip84 -> ChildFromIndex.get(private_key, 84, true)
        _ -> {:ok, private_key}
      end

    {child_private_key, derivation_path}
  end

  defp maybe_derive_coin_type({%PrivateKey{}, %DerivationPath{coin_type: nil}} = hash) do
    hash
  end

  defp maybe_derive_coin_type(
         {%PrivateKey{} = private_key, %DerivationPath{coin_type: coin_type} = derivation_path}
       ) do
    {:ok, child_private_key} =
      case coin_type do
        :bitcoin -> ChildFromIndex.get(private_key, 0, true)
        :bitcoin_testnet -> ChildFromIndex.get(private_key, 1, true)
        _ -> {:ok, private_key}
      end

    {child_private_key, derivation_path}
  end

  defp maybe_derive_account({%PrivateKey{}, %DerivationPath{account: nil}} = hash) do
    hash
  end

  defp maybe_derive_account(
         {private_key,
          %DerivationPath{account: %Level{hardened?: true, value: account}} = derivation_path}
       ) do
    {:ok, child_private_key} = ChildFromIndex.get(private_key, account, true)

    {child_private_key, derivation_path}
  end

  defp maybe_derive_change({%PrivateKey{}, %DerivationPath{change: nil}} = hash) do
    hash
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

  defp maybe_derive_address_index({%PrivateKey{}, %DerivationPath{address_index: nil}} = hash) do
    hash
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
