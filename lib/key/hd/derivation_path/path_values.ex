defmodule BitcoinLib.Key.HD.DerivationPath.PathValues do
  @moduledoc """
  Single purpose module that's responsible to transform a list of integer into
  a DerivationPath values structure
  """
  @enforce_keys [:type]

  defstruct [:type, :purpose, :network, :account, :change, :address_index]

  alias BitcoinLib.Key.HD.DerivationPath.PathValues

  @type t :: PathValues

  @doc """
  Transform a list of integer into a DerivationPath values structure

  ## Examples
      iex> ["m", 0x80000000, 0x80000000, 0x80000005]
      ...> |> BitcoinLib.Key.HD.DerivationPath.PathValues.from_list
      %BitcoinLib.Key.HD.DerivationPath.PathValues{
        type: "m",
        purpose: 0x80000000,
        network: 0x80000000,
        account: 0x80000005
      }
  """
  @spec from_list(list()) :: PathValues.t()
  def from_list([type | remaining_values]) do
    {purpose, remaining_values} = extract_first_value(remaining_values)
    {network, remaining_values} = extract_first_value(remaining_values)
    {account, remaining_values} = extract_first_value(remaining_values)
    {change, remaining_values} = extract_first_value(remaining_values)
    {address_index, _remaining_values} = extract_first_value(remaining_values)

    %PathValues{
      type: type,
      purpose: purpose,
      network: network,
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
