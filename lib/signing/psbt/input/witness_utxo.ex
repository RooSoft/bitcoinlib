defmodule BitcoinLib.Signing.Psbt.Input.WitnessUtxo do
  @moduledoc """
  A witness UTXO in a partially signed bitcoin transaction's input
  """

  defstruct [:amount, :script_pub_key]

  alias BitcoinLib.Signing.Psbt.Input.WitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Script

  @type t :: WitnessUtxo

  @bits 8

  # TODO: document
  @spec parse(Keypair.t()) :: {:ok, WitnessUtxo.t()} | {:error, binary()}
  def parse(keypair) do
    %{keypair: keypair}
    |> validate_keypair()
    |> extract_amount()
    |> extract_script_pub_key()
    |> validate_script_pub_key()
    |> create_output()
  end

  defp create_output(%{error: message}), do: {:error, message}

  defp create_output(%{amount: amount, script_pub_key: script_pub_key}) do
    witness_utxo = %WitnessUtxo{
      amount: amount,
      script_pub_key: script_pub_key
    }

    {:ok, witness_utxo}
  end

  defp validate_keypair(%{keypair: keypair} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        Map.put(map, :error, "invalid witness utxo key")
    end
  end

  defp extract_amount(%{error: _message} = map), do: map

  defp extract_amount(
         %{
           keypair: %Keypair{
             value: %Value{data: <<amount::little-64, remaining::bitstring>>}
           }
         } = map
       ) do
    map
    |> Map.put(:amount, amount)
    |> Map.put(:remaining, remaining)
  end

  defp extract_script_pub_key(%{error: _message} = map), do: map

  defp extract_script_pub_key(%{remaining: remaining} = map) do
    %CompactInteger{value: script_pub_key_length, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    script_pub_key_length_in_bits = script_pub_key_length * @bits

    <<script_pub_key::bitstring-size(script_pub_key_length_in_bits), remaining::bitstring>> =
      remaining

    case Script.parse(script_pub_key) do
      {:ok, script} ->
        %{map | remaining: remaining}
        |> Map.put(:script_pub_key, script)

      {:error, message} ->
        Map.put(map, :error, message)
    end
  end

  defp validate_script_pub_key(%{error: _message} = map), do: map

  defp validate_script_pub_key(%{script_pub_key: script_pub_key} = map) do
    id =
      script_pub_key
      |> Script.Analyzer.identify()

    case id do
      {:p2sh, _script_hash} ->
        map

      {:p2wsh, _script_hash} ->
        map

      {:p2wpkh, _key_hash} ->
        map

      {script_type, _value} ->
        formatted_script_type = Atom.to_string(script_type) |> String.upcase()
        message = "a witness UTXO contains a #{formatted_script_type} script"

        Map.put(map, :error, message)
    end
  end
end
