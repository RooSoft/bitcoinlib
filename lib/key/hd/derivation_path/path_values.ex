defmodule BitcoinLib.Key.HD.DerivationPath.PathValues do
  @enforce_keys [:type]

  defstruct [:type, :purpose, :coin_type, :account, :change, :address_index]

  alias BitcoinLib.Key.HD.DerivationPath.PathValues

  def from_list([type | remaining_values]) do
    {purpose, remaining_values} = extract_first_value(remaining_values)
    {coin_type, remaining_values} = extract_first_value(remaining_values)
    {account, remaining_values} = extract_first_value(remaining_values)
    {change, remaining_values} = extract_first_value(remaining_values)
    {address_index, _remaining_values} = extract_first_value(remaining_values)

    %PathValues{
      type: type,
      purpose: purpose,
      coin_type: coin_type,
      account: account,
      change: change,
      address_index: address_index
    }
  end

  defp extract_first_value([]), do: {nil, []}

  defp extract_first_value([first_value]), do: {first_value, []}

  defp extract_first_value([first_value | remaining_list]) do
    {first_value, remaining_list}
  end
end
