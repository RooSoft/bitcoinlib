defmodule BitcoinLib.Transaction do
  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/transaction-data#fields
  """
  defstruct [:version, :id, :inputs, :outputs, :locktime, witness: []]

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Encoder, Decoder, Signer}

  @doc """
  Converts a hex binary into a %Transaction{}

  ## Examples
      iex> "01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000"
      ...> |> BitcoinLib.Transaction.parse()
      {
        :ok,
        %BitcoinLib.Transaction{
          version: 1,
          id: "c80b343d2ce2b5d829c2de9854c7c8d423c0e33bda264c40138d834aab4c0638",
          inputs: [
            %BitcoinLib.Transaction.Input{
              txid: "3f4fa19803dec4d6a84fae3821da7ac7577080ef75451294e71f9b20e0ab1e7b",
              vout: 0,
              script_sig: [],
              sequence: 4294967295
            }
          ],
          outputs: [
            %BitcoinLib.Transaction.Output{
              value: 4999990000,
              script_pub_key: [
                %BitcoinLib.Script.Opcodes.Stack.Dup{},
                %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
                %BitcoinLib.Script.Opcodes.Data{value: <<0xcbc20a7664f2f69e5355aa427045bc15e7c6c772::160>>},
                %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
                %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac::200>>}
              ]
            }
          ],
          locktime: 0
        }
      }
  """
  @spec parse(binary()) :: {:ok, %Transaction{}} | {:error, binary()}
  def parse(hex_transaction) do
    hex_transaction
    |> Binary.from_hex()
    |> decode()
  end

  @doc """
  Converts a bitstring into a %Transaction{}

  ## Examples
      iex> <<0x01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000::680>>
      ...> |> BitcoinLib.Transaction.decode()
      {
        :ok,
        %BitcoinLib.Transaction{
          version: 1,
          id: "c80b343d2ce2b5d829c2de9854c7c8d423c0e33bda264c40138d834aab4c0638",
          inputs: [
            %BitcoinLib.Transaction.Input{
              txid: "3f4fa19803dec4d6a84fae3821da7ac7577080ef75451294e71f9b20e0ab1e7b",
              vout: 0,
              script_sig: [],
              sequence: 4294967295
            }
          ],
          outputs: [
            %BitcoinLib.Transaction.Output{
              value: 4999990000,
              script_pub_key: [
                %BitcoinLib.Script.Opcodes.Stack.Dup{},
                %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
                %BitcoinLib.Script.Opcodes.Data{value: <<0xcbc20a7664f2f69e5355aa427045bc15e7c6c772::160>>},
                %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
                %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac::200>>}
              ]
            }
          ],
          locktime: 0
        }
      }
  """
  @spec decode(bitstring()) :: {:ok, %Transaction{}} | {:error, binary()}
  def decode(encoded_transaction) do
    encoded_transaction
    |> Decoder.to_struct()
  end

  @doc """
  Encodes a transaction into binary format

  based on https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6

  ## Examples
      iex> transaction = %BitcoinLib.Transaction{
      ...>   inputs: [
      ...>     %BitcoinLib.Transaction.Input{
      ...>       script_sig: nil,
      ...>       sequence: 0xFFFFFFFF,
      ...>       txid: "5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44",
      ...>       vout: 1
      ...>     }
      ...>   ],
      ...>   outputs: [
      ...>     %BitcoinLib.Transaction.Output{
      ...>       script_pub_key: [
      ...>         %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>         %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>         %BitcoinLib.Script.Opcodes.Data{value: <<0xf86f0bc0a2232970ccdf4569815db500f1268361::160>>},
      ...>         %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>         %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...>       ],
      ...>       value: 129000000
      ...>     }
      ...>   ],
      ...>   locktime: 0,
      ...>   version: 1
      ...> }
      ...> BitcoinLib.Transaction.encode(transaction)
      <<0x0100000001449d45bbbfe7fc93bbe649bb7b6106b248a15da5dbd6fdc9bdfc7efede83235e0100000000ffffffff014062b007000000001976a914f86f0bc0a2232970ccdf4569815db500f126836188ac00000000::680>>
  """
  @spec encode(%Transaction{}) :: binary()
  def encode(%Transaction{} = transaction) do
    transaction
    |> Encoder.from_struct()
  end

  @doc """
  Checks if a transaction is NOT signed

  ## Examples
      iex> %BitcoinLib.Transaction{
      ...>   inputs: [
      ...>     %BitcoinLib.Transaction.Input{
      ...>       txid: "39bc5c3b33d66ce3d7852a7942331e3ec10f8ba50f225fc41fb5dfa523239a27",
      ...>       vout: 0,
      ...>       script_sig: [],
      ...>       sequence: 4294967295
      ...>     }
      ...>   ]
      ...> }
      ...> |> BitcoinLib.Transaction.check_if_unsigned
      true
  """
  @spec check_if_unsigned(%Transaction{}) :: boolean()
  def check_if_unsigned(%Transaction{inputs: inputs}) do
    inputs
    |> Enum.reduce(true, fn input, unsigned? ->
      unsigned? && input.script_sig == []
    end)
  end

  @doc """
  Signs a transaction and transforms it into a binary that can be sent to the network

  ## Examples
      iex>  private_key = BitcoinLib.Key.PrivateKey.from_seed_phrase(
      ...>    "rally celery split order almost twenty ignore record legend learn chaos decade"
      ...>  )
      ...>  %BitcoinLib.Transaction{
      ...>    version: 1,
      ...>    inputs: [
      ...>      %BitcoinLib.Transaction.Input{
      ...>        txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
      ...>        vout: 0,
      ...>        sequence: 0xFFFFFFFF,
      ...>        script_sig: <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>> |> BitcoinLib.Script.parse!()
      ...>      }
      ...>    ],
      ...>    outputs: [%BitcoinLib.Transaction.Output{
      ...>       script_pub_key: <<0x76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac::360>> |> BitcoinLib.Script.parse!(),
      ...>       value: 10_000}
      ...>    ],
      ...>    locktime: 0
      ...>  }
      ...>  |> BitcoinLib.Transaction.sign_and_encode(private_key)
      "0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000006a47304402207d2ff650acf4bd2f413dc04ded50fbbfc315bcb0aa97636b3c4caf55333d1c6a02207590f62363b2263b3d9b65dad3cd56e840e0d61dc0feab8f7e7956831c7e5103012102702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3ffffffff0110270000000000002d76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac00000000"
  """
  @spec sign_and_encode(%Transaction{}, %PrivateKey{}) :: binary()
  def sign_and_encode(%Transaction{} = transaction, %PrivateKey{} = private_key) do
    Signer.sign_and_encode(transaction, private_key)
  end
end

defimpl Inspect, for: BitcoinLib.Transaction do
  alias BitcoinLib.Transaction
  alias BitcoinLib.Formatting.HexBinary

  def inspect(%Transaction{} = transaction, opts) do
    %{
      transaction
      | witness: format_witness(transaction.witness)
    }
    |> Inspect.Any.inspect(opts)
  end

  defp format_witness(witness) do
    witness
    |> Enum.map(&format_witness_item/1)
  end

  defp format_witness_item(witness_item) do
    %HexBinary{data: witness_item}
  end
end
