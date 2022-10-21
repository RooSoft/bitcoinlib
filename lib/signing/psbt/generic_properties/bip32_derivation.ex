defmodule BitcoinLib.Signing.Psbt.GenericProperties.Bip32Derivation do
  defstruct [:pub_key, :master_key_fingerprint, :derivation_path]

  @compressed_pub_key_size 33
  @uncompressed_pub_key_size 65

  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Signing.Psbt.GenericProperties.Bip32Derivation
  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.HD.DerivationPath

  # TODO: document
  def parse(%Keypair{key: %Key{data: binary_pub_key}, value: %Value{data: remaining}}) do
    {master_key_fingerprint, remaining} = extract_master_key_fingerprint(remaining)
    {derivation_path, _remaining} = extract_derivation_path(remaining, [])

    %Bip32Derivation{
      pub_key: %PublicKey{key: binary_pub_key},
      master_key_fingerprint: master_key_fingerprint,
      derivation_path: DerivationPath.from_list(["M" | derivation_path])
    }
    |> validate_pub_key()
    |> validate_derivation_path()
  end

  defp extract_master_key_fingerprint(<<fingerprint::bitstring-32, remaining::bitstring>>) do
    {fingerprint, remaining}
  end

  defp extract_derivation_path(<<>> = remaining, path) do
    {Enum.reverse(path), remaining}
  end

  defp extract_derivation_path(<<level::little-32, remaining::bitstring>>, path) do
    extract_derivation_path(remaining, [level | path])
  end

  defp validate_pub_key(%Bip32Derivation{pub_key: pub_key} = bip32_derivation) do
    case byte_size(pub_key.key) do
      @compressed_pub_key_size ->
        bip32_derivation

      @uncompressed_pub_key_size ->
        bip32_derivation

      wrong_size ->
        bip32_derivation
        |> Map.put(:error, "wrong pub key size, which is #{wrong_size} in hex format")
    end
  end

  defp validate_derivation_path(
         %Bip32Derivation{derivation_path: derivation_path} = bip32_derivation
       ) do
    derivation_path =
      derivation_path
      |> validate_coin_type

    case(Map.get(derivation_path, :error)) do
      nil ->
        bip32_derivation

      message ->
        bip32_derivation
        |> Map.put(:error, message)
    end
  end

  # defp validate_purpose(%DerivationPath{purpose: :invalid} = derivation_path) do
  #   derivation_path
  #   |> Map.put(:error, "invalid purpose in derivation path")
  #   |> IO.inspect()
  # end

  # defp validate_purpose(derivation_path), do: derivation_path

  defp validate_coin_type(%DerivationPath{coin_type: :invalid} = derivation_path) do
    derivation_path
    |> Map.put(:error, "invalid coin type in derivation path")
  end

  defp validate_coin_type(derivation_path), do: derivation_path
end

defimpl Inspect, for: BitcoinLib.Signing.Psbt.GenericProperties.Bip32Derivation do
  alias BitcoinLib.Signing.Psbt.GenericProperties.Bip32Derivation
  alias BitcoinLib.Formatting.HexBinary

  def inspect(%Bip32Derivation{} = bip32_derivation, opts) do
    %{
      bip32_derivation
      | master_key_fingerprint: %HexBinary{data: bip32_derivation.master_key_fingerprint}
    }
    |> Inspect.Any.inspect(opts)
  end
end
