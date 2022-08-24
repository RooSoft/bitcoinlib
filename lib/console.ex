defmodule BitcoinLib.Console do
  alias BitcoinLib.Key.{PrivateKey, PublicKey}

  @defaults %{serialization_format: nil}

  def write(key, opts \\ [])

  def write(%PrivateKey{} = private_key, opts) do
    %{serialization_format: _serialization_format} = Enum.into(opts, @defaults)

    tabulation = 19
    base58_key = Base58.encode(private_key.key)

    print_header("PRIVATE_KEY", tabulation)

    print_with_title(
      "fingerprint",
      tabulation,
      private_key.fingerprint |> Integer.to_string(16) |> String.downcase()
    )

    maybe_print_serialized_version(tabulation, private_key)
    print_with_title("key", tabulation, private_key.key, 64)
    print_with_title("base58 key", tabulation, base58_key)
    print_with_title("chain_code", tabulation, private_key.chain_code, 64)
    print_with_title("depth", tabulation, private_key.depth)

    print_with_title(
      "index",
      tabulation,
      private_key.index |> Integer.to_string(16) |> String.downcase()
    )

    print_with_title(
      "parent fingerprint",
      tabulation,
      private_key.parent_fingerprint |> Integer.to_string(16) |> String.downcase()
    )

    private_key
  end

  def write(%PublicKey{} = public_key, opts) do
    %{serialization_format: serialization_format} = Enum.into(opts, @defaults)

    tabulation = 19
    base58_key = Base58.encode(public_key.key)

    IO.puts("PUBLIC KEY")
    IO.puts("----------")

    print_with_title(
      "fingerprint",
      tabulation,
      public_key.fingerprint |> Integer.to_string(16) |> String.downcase()
    )

    maybe_print_serialized_version(tabulation, public_key, serialization_format)
    print_with_title("key", tabulation, public_key.key, 66)
    print_with_title("base58 key", tabulation, base58_key)
    print_with_title("chain_code", tabulation, public_key.chain_code, 64)
    print_with_title("depth", tabulation, public_key.depth)

    print_with_title(
      "index",
      tabulation,
      public_key.index |> Integer.to_string(16) |> String.downcase()
    )

    print_with_title(
      "parent fingerprint",
      tabulation,
      public_key.parent_fingerprint |> Integer.to_string(16) |> String.downcase()
    )

    public_key
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
    IO.puts("#{blue(title |> String.pad_leading(title_length, " "))}: #{yellow(value)}")
  end

  defp maybe_print_serialized_version(_title_length, _value, nil) do
  end

  defp maybe_print_serialized_version(title_length, %PublicKey{} = public_key, format) do
    print_with_title("serialized", title_length, PublicKey.serialize!(public_key, format))
  end

  defp maybe_print_serialized_version(title_length, %PrivateKey{} = private_key) do
    print_with_title("serialized", title_length, PrivateKey.serialize(private_key))
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
