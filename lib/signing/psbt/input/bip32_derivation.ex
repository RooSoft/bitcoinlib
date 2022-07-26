defmodule BitcoinLib.Signing.Psbt.Input.Bip32Derivation do
  defstruct [:pub_key, :fingerprint, :derivation_path]

  alias BitcoinLib.Signing.Psbt.Input.Bip32Derivation

  def parse(binary_pub_key, remaining) do
    {fingerprint, remaining} = extract_fingerprint(remaining)
    {derivation_path, _remaining} = extract_derivation_path(remaining, [])

    %Bip32Derivation{
      pub_key: Binary.to_hex(binary_pub_key),
      fingerprint: Integer.to_string(fingerprint, 16) |> String.downcase(),
      derivation_path: derivation_path
    }
  end

  defp extract_fingerprint(<<fingerprint::32, remaining::bitstring>>) do
    {fingerprint, remaining}
  end

  defp extract_derivation_path(<<>> = remaining, path) do
    {Enum.reverse(path), remaining}
  end

  defp extract_derivation_path(<<level::little-32, remaining::bitstring>>, path) do
    extract_derivation_path(remaining, [level | path])
  end
end
