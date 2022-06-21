defmodule BitcoinLib.Helpers do
  def to_fixed_hex_string(value, length) when is_integer(value) do
    value
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(length, "0")
  end

  def print_with_title(title, title_length, value, length)
      when is_integer(value) and is_integer(length) do
    formatted_value = value |> to_fixed_hex_string(length)

    print_with_title(title, title_length, formatted_value)
  end

  def print_with_title(title, title_length, value)
      when is_integer(value) do
    formatted_value = Integer.to_string(value)

    print_with_title(title, title_length, formatted_value)
  end

  def print_with_title(title, title_length, value) when is_binary(value) do
    IO.puts(
      "#{IO.ANSI.yellow()}#{title |> String.pad_leading(title_length, " ")}: #{IO.ANSI.default_color()}#{value}"
    )
  end
end
