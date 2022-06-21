defmodule BitcoinLib.Console do
  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic}

  def write(%ExtendedPrivate{} = private_key) do
    tabulation = 12

    print_header("PRIVATE_KEY", tabulation)

    print_with_title("key", tabulation, private_key.key, 64)
    print_with_title("chain_code", tabulation, private_key.chain_code, 64)
    print_with_title("depth", tabulation, private_key.depth)
    print_with_title("index", tabulation, private_key.index)
    print_with_title("fingerprint", tabulation, private_key.parent_fingerprint)
  end

  def write(%ExtendedPublic{} = public_key) do
    tabulation = 12

    IO.puts("PUBLIC KEY")
    IO.puts("----------")

    print_with_title("key", tabulation, public_key.key, 66)
    print_with_title("chain_code", tabulation, public_key.chain_code, 64)
    print_with_title("depth", tabulation, public_key.depth)
    print_with_title("index", tabulation, public_key.index)
    print_with_title("fingerprint", tabulation, public_key.parent_fingerprint)
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
    IO.puts("#{blue(title |> String.pad_leading(title_length, " "))}: #{yellow value}")
  end

  defp print_header(header, tabulation) do
    header_length = String.length(header)
    underline = "" |> String.pad_leading(header_length, "-")

    IO.puts("#{"" |> String.pad_leading(tabulation + 2)}#{blue(header)}")
    IO.puts("#{"" |> String.pad_leading(tabulation + 2)}#{underline}")
  end

  defp yellow(string) do
    "#{IO.ANSI.yellow()}#{string}#{IO.ANSI.default_color()}"
  end

  defp blue(string) do
    "#{IO.ANSI.blue()}#{string}#{IO.ANSI.default_color()}"
  end
end
