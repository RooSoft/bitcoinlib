defmodule BitcoinLib.Signing.Psbt.Input.WitnessUtxo do
  defstruct [:sixty_four, :pub_key]

  alias BitcoinLib.Signing.Psbt.Input.WitnessUtxo
  alias BitcoinLib.Signing.Psbt.CompactInteger

  def parse(<<sixty_four::binary-8, remaining::bitstring>>) do
    {pub_key, remaining} = parse_pub_key(remaining)

    {%WitnessUtxo{sixty_four: Binary.to_hex(sixty_four), pub_key: pub_key}, remaining}
  end

  defp parse_pub_key(remaining) do
    %CompactInteger{value: pub_key_length, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    <<pub_key::binary-size(pub_key_length), remaining::bitstring>> = remaining

    {Binary.to_hex(pub_key), remaining}
  end
end
