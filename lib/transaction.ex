defmodule BitcoinLib.Transaction do
  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/transaction-data#fields
  """
  defstruct [:version, :id, :inputs, :outputs, :locktime, :segwit?, coinbase?: false, witness: []]

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Encoder, Decoder, Signer}

  @type t :: Transaction

  @doc """
  Converts a hex binary into a %Transaction{} and the remaining unused data

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
          locktime: 0,
          segwit?: false
        },
        <<>>
      }
  """
  @spec parse(binary()) :: {:ok, Transaction.t(), bitstring()} | {:error, binary()}
  def parse(hex_transaction) do
    hex_transaction
    |> Binary.from_hex()
    |> decode()
  end

  @doc """
  Converts a bitstring into a %Transaction{} and the remaining unused data

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
          locktime: 0,
          segwit?: false
        },
        <<>>
      }
  """
  @spec decode(bitstring()) :: {:ok, Transaction.t(), bitstring()} | {:error, binary()}
  def decode(encoded_transaction) do
    with {:ok, transaction, remaining} <- Decoder.to_struct(encoded_transaction) do
      transaction =
        transaction
        |> add_id()
        |> Map.put(:coinbase?, transaction.coinbase?)

      {:ok, transaction, remaining}
    else
      {:error, message} -> {:error, message}
    end
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
  @spec encode(Transaction.t()) :: binary()
  def encode(%Transaction{} = transaction) do
    transaction
    |> Encoder.from_struct()
  end

  @doc """
  Computes a transaction's ID and adds it to its own structure

  ## Examples
      iex> %BitcoinLib.Transaction{
      ...>   version: 2,
      ...>   inputs: [
      ...>     %BitcoinLib.Transaction.Input{
      ...>       txid: "5a957f4bff6d23140eb7e9b6fcedd41d3febf1e145d37519c593c939789a49af",
      ...>       vout: 0,
      ...>       script_sig: [],
      ...>       sequence: 4294967293
      ...>     }
      ...>   ],
      ...>   outputs: [
      ...>     %BitcoinLib.Transaction.Output{
      ...>       value: 1303734,
      ...>       script_pub_key: [%BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>        %BitcoinLib.Script.Opcodes.Data{value: <<0x05e17c02fb238ca0779b3533271ebe916b01bcab::160>>},
      ...>        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a91405e17c02fb238ca0779b3533271ebe916b01bcab88ac::200>>}]
      ...>     }
      ...>   ],
      ...>   locktime: 2378041,
      ...>   witness: []
      ...> }
      ...> |> BitcoinLib.Transaction.add_id()
      %BitcoinLib.Transaction{
        version: 2,
        id: "b62e9d36389427d39e5d438a05045c23d1938e4242661c5fe2ad87c46337b091",
        inputs: [
          %BitcoinLib.Transaction.Input{
            txid: "5a957f4bff6d23140eb7e9b6fcedd41d3febf1e145d37519c593c939789a49af",
            vout: 0,
            script_sig: [],
            sequence: 4294967293
          }
        ],
        outputs: [
          %BitcoinLib.Transaction.Output{
            value: 1303734,
            script_pub_key: [%BitcoinLib.Script.Opcodes.Stack.Dup{},
            %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
            %BitcoinLib.Script.Opcodes.Data{value: <<0x05e17c02fb238ca0779b3533271ebe916b01bcab::160>>},
            %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
            %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a91405e17c02fb238ca0779b3533271ebe916b01bcab88ac::200>>}]
          }
        ],
        locktime: 2378041,
        witness: []
      }
  """
  @spec add_id(Transaction.t()) :: Transaction.t()
  def add_id(%Transaction{} = transaction) do
    Map.put(transaction, :id, to_id(transaction))
  end

  @doc """
  Hashes the transaction's id

  ## Examples
      iex> %BitcoinLib.Transaction{
      ...>   version: 2,
      ...>   inputs: [
      ...>     %BitcoinLib.Transaction.Input{
      ...>       txid: "5a957f4bff6d23140eb7e9b6fcedd41d3febf1e145d37519c593c939789a49af",
      ...>       vout: 0,
      ...>       script_sig: [],
      ...>       sequence: 4294967293
      ...>     }
      ...>   ],
      ...>   outputs: [
      ...>     %BitcoinLib.Transaction.Output{
      ...>       value: 1303734,
      ...>       script_pub_key: [%BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>        %BitcoinLib.Script.Opcodes.Data{value: <<0x05e17c02fb238ca0779b3533271ebe916b01bcab::160>>},
      ...>        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a91405e17c02fb238ca0779b3533271ebe916b01bcab88ac::200>>}]
      ...>     }
      ...>   ],
      ...>   locktime: 2378041,
      ...>   witness: []
      ...> }
      ...> |> BitcoinLib.Transaction.to_id()
      "b62e9d36389427d39e5d438a05045c23d1938e4242661c5fe2ad87c46337b091"
  """
  @spec to_id(Transaction.t()) :: binary()
  def to_id(%Transaction{} = transaction) do
    transaction
    |> Encoder.for_txid()
    |> Crypto.double_sha256()
    |> Crypto.Bitstring.reverse()
    |> Binary.to_hex()
  end

  @doc """
  Computes a transaction id from an encoded transaction in bitstring format

  ## Examples
      A random transaction

      iex> "010000000001016dc77969a38fcd7ade1524658b7cf04430eefcbed5ed18e8907f938932ee6b360100000000f5ffffff02404b4c000000000017a9140403fb8f4a93093430e338f346efe40774b45f95873c75360000000000160014a79e4076fca80a3742536d1d5cd364d5cfe0eeaf02483045022100ff621967f1a0c231dbdaf500a83079d4a5c32e64e2d6b3809ff47ee25c7750ca0220326d95db84811e391af38aded348c8f26cdf793be3ed19ae1185cc03aef42fa8012102b57b7b110b4c00ae0f2ed1594174ebcc2f4077667867ba2cb514bbf59ae8868500000000"
      ...> |> Binary.from_hex()
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "651560f701575fb0b15780b6ba771bf6096b1d6b6c6202b3d79915ebbac5ebff"}

      The transaction in the genesis block

      iex> "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
      ...> |> Binary.from_hex()
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"}

      From real world ElectrumClient example

      iex> "0200000000010135b0b1e0f2c3c5e2e4b96b501893b3b8f649701faf97e3b51ca60e672ae1b6970100000000fdffffff03881300000000000016001413bfff2d6dd02b8837f156c6f9fe0ea7363df79570170000000000002200206ff04018aff3bd320c89e2e8c9d4274e6b0e780975cd364810239ecc7bd8138a60220000000000001600147801fc793b86a3d81801588ffb4f3c4b11f704090247304402201530b7cf8beda625ad29280ef342c22518ea7df543060cb9966a81cde8b18c6f02205c23cf17627815805bbc5814ece5ea1f7f89e16ac373b19de9f40944588de1220121033c3fdfa1a29b984e83be8fc5b952558a0837734a0df0b663764e6c665c3e9e5b1ea40b00"
      ...> |> Binary.from_hex()
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "f318dd60cc36fb1238e39abf697b471881ed811f2f66b0bdeed15e29d3032c76"}

      From https://learnmeabitcoin.com/technical/txid

      iex> "01000000000101c6548bbe4e6a1bc65c2b6546b15c5bcb17682d0418d866632ec5328f0e6c46420000000000ffffffff02dcc5630000000000160014349a727852238d54d2d98662b72ba19d48dafea1c01d13000000000017a9140efd4916baef33b979989542f21a4e182a992bf6870247304402207b6a1d52a7bcfc87b776f3946a5c57fc686828131f87603f0e87b9c5cddfe4d90220405070bac780bf313df38c174313a48437e67eedf3234ef0770760d005f9182e012102b173048a5b94939f9486826d41b87add8a20910f7ff8acadabb5f89edbd0da9b00000000"
      ...> |> Binary.from_hex()
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "c7fbe3f35f6060555279ba455c1c4d419ceaaa1a5fe68940913a431296d37f5b"}

      iex> <<0x0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423edce25857fcd3704000000004847304402204e45e16932b8af514961a1d3a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07de4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f7159b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7303b8a0626f1baded5c72a704f7e6cd84cac00286bee0000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000::2200>>
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16"}

      iex> "02000000000101fabb6b29687f2047622f546cc97aedce4407da5d96b7f7d72e53c7fdbae9b5930100000000fdffffff02e63be7390000000017a9140e825b4005779df0808738f3beabcee7abe5b46687436b1200000000001976a9146b426bed96ace2804e99f29304a9eb1b1260ea6688ac0247304402207e39cfe660bc35ab24229a820d847aa97b3dfd96623cc5b6cc679d11215d2b3402201a7a2ddda43b8698968e38fc44a967a86d0e088103b24695e79c091c6139754b012103ee237db683c637ddf2bd51bc39555084dcc402599625bb1a2ec02fd2a1a79ddeaba40b00"
      ...> |> Binary.from_hex()
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "6991e107b306fa1629f3b41054ec856dbcc379aac28cc8c84102163d03239f88"}

      Another one based on https://bitcoin.stackexchange.com/a/2233/101041

      iex> <<0x01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000::1632>>
      ...> |> BitcoinLib.Transaction.id_from_encoded_transaction()
      {:ok, "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"}
  """
  @spec id_from_encoded_transaction(bitstring()) :: {:ok, binary()} | {:error, binary()}
  def id_from_encoded_transaction(encoded_transaction) do
    with {:ok, transaction, <<>>} <- Decoder.to_struct(encoded_transaction) do
      {:ok, to_id(transaction)}
    else
      {:error, message} -> {:error, message}
    end
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
  @spec check_if_unsigned(Transaction.t()) :: boolean()
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
  @spec sign_and_encode(Transaction.t(), PrivateKey.t()) :: binary()
  def sign_and_encode(%Transaction{} = transaction, %PrivateKey{} = private_key) do
    Signer.sign_and_encode(transaction, private_key)
  end

  @doc """
  Signs a transaction and transforms it into a binary that can be sent to the network

  ## Examples
      iex>  %BitcoinLib.Transaction{
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
      ...>  |> BitcoinLib.Transaction.strip_signatures()
      %BitcoinLib.Transaction{
        version: 1,
        inputs: [
          %BitcoinLib.Transaction.Input{
            txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
            vout: 0,
            sequence: 0xFFFFFFFF,
            script_sig: []
          }
        ],
        outputs: [%BitcoinLib.Transaction.Output{
          script_pub_key: <<0x76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac::360>> |> BitcoinLib.Script.parse!(),
          value: 10_000}
        ],
        locktime: 0
      }
      |> BitcoinLib.Transaction.strip_signatures()
  """
  @spec strip_signatures(Transaction.t()) :: Transaction.t()
  def strip_signatures(%Transaction{inputs: inputs} = transaction) do
    inputs_without_signatures =
      inputs
      |> Enum.map(&Input.strip_signature/1)

    %{transaction | inputs: inputs_without_signatures}
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
    |> Enum.map(fn input_witnesses ->
      input_witnesses
      |> Enum.map(&format_witness_item/1)
    end)
  end

  defp format_witness_item(witness_item) do
    %HexBinary{data: witness_item}
  end
end
