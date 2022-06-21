defmodule BitcoinLib.Console do
  alias BitcoinLib.Key.HD.ExtendedPrivate

  def write(%ExtendedPrivate{} = private_key) do
    tabulation = 12

    print_with_title("key", tabulation, private_key.key, 64)
    print_with_title("chain_code", tabulation, private_key.chain_code, 64)
    print_with_title("depth", tabulation, private_key.depth)
    print_with_title("index", tabulation, private_key.index)
    print_with_title("fingerprint", tabulation, private_key.parent_fingerprint)
  end

  defp to_fixed_hex_string(value, length) when is_integer(value) do
    value
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(length, "0")
  end

  defp print_with_title(title, title_length, value, length)
       when is_integer(value) and is_integer(length) do
    formatted_value = value |> to_fixed_hex_string(length)

    print_with_title(title, title_length, formatted_value)
  end

  defp print_with_title(title, title_length, value)
       when is_integer(value) do
    formatted_value = Integer.to_string(value)

    print_with_title(title, title_length, formatted_value)
  end

  defp print_with_title(title, title_length, value) when is_binary(value) do
    IO.puts(
      "#{IO.ANSI.yellow()}#{title |> String.pad_leading(title_length, " ")}: #{IO.ANSI.default_color()}#{value}"
    )
  end
end
