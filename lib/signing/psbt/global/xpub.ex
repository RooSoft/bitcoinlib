defmodule BitcoinLib.Signing.Psbt.Global.Xpub do
  @moduledoc """
  An xpub in a partially signed bitcoin transaction
  """

  defstruct [:fingerprint, :path_elements]

  alias BitcoinLib.Signing.Psbt.Global.Xpub

  # TODO: document
  def parse(<<fingerprint::binary-4, remaining::bitstring>>) do
    {path_elements, remaining} =
      remaining
      |> extract_path_elements([])

    {%Xpub{fingerprint: fingerprint, path_elements: Enum.reverse(path_elements)}, remaining}
  end

  defp extract_path_elements(<<>> = remaining, elements) do
    {elements, remaining}
  end

  defp extract_path_elements(<<element::little-32, remaining::bitstring>>, elements) do
    extract_path_elements(remaining, [element | elements])
  end
end
