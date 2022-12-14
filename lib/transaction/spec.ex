defmodule BitcoinLib.Transaction.Spec do
  @moduledoc """
  A simplified version of a %BitcoinLib.Transaction that can be filled with human readable formats
  """

  defstruct version: 2, inputs: [], outputs: [], locktime: 2_404_140

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Script
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Spec

  @type t :: %Spec{}

  @doc """
  Adds a human readable input into a transaction spec

  ## Examples
      iex> %BitcoinLib.Transaction.Spec{}
      ...> |> BitcoinLib.Transaction.Spec.add_input!(
      ...>   txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
      ...>   vout: 1,
      ...>   redeem_script: "76a914c39658833d83f2299416e697af2fb95a998853d388ac"
      ...> )
      %BitcoinLib.Transaction.Spec{
        inputs: [
          %BitcoinLib.Transaction.Spec.Input{
            txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
            vout: 1,
            redeem_script: [
              %BitcoinLib.Script.Opcodes.Stack.Dup{},
              %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
              %BitcoinLib.Script.Opcodes.Data{value: <<0xc39658833d83f2299416e697af2fb95a998853d3::160>>},
              %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
              %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914c39658833d83f2299416e697af2fb95a998853d388ac::200>>}
            ]
          }
        ],
        outputs: []
      }
  """
  @spec add_input!(Spec.t(), binary() | list()) :: Spec.t()
  def add_input!(
        %Spec{} = spec,
        txid: txid,
        vout: vout,
        redeem_script: redeem_script
      )
      when is_binary(redeem_script) do
    {:ok, parsed_redeem_script} =
      redeem_script
      |> Binary.from_hex()
      |> Script.parse()

    Spec.add_input!(spec,
      txid: txid,
      vout: vout,
      redeem_script: parsed_redeem_script
    )
  end

  @spec add_input!(Spec.t(), txid: binary(), vout: integer(), redeem_script: list()) :: Spec.t()
  def add_input!(%Spec{inputs: inputs} = spec,
        txid: txid,
        vout: vout,
        redeem_script: redeem_script
      )
      when is_list(redeem_script) do
    input_spec = %Spec.Input{
      txid: txid,
      vout: vout,
      redeem_script: redeem_script
    }

    %{spec | inputs: [input_spec | inputs]}
  end

  @doc """
  Adds a human readable output into a transaction spec

  ## Examples
      iex> p2pkh_script = BitcoinLib.Script.Types.P2pkh.create(<<0xad6a62e2d23d1c060897cd0cc79c42dad715e4c7::160>>)
      ...> amount = 1000
      ...> transaction_spec = %BitcoinLib.Transaction.Spec{}
      ...> transaction_spec
      ...> |> BitcoinLib.Transaction.Spec.add_output(p2pkh_script, amount)
      %BitcoinLib.Transaction.Spec{
        inputs: [],
        outputs: [%BitcoinLib.Transaction.Spec.Output{
          script_pub_key: [
            %BitcoinLib.Script.Opcodes.Stack.Dup{},
            %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
            %BitcoinLib.Script.Opcodes.Data{value: <<0xad6a62e2d23d1c060897cd0cc79c42dad715e4c7::160>>},
            %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
            %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914ad6a62e2d23d1c060897cd0cc79c42dad715e4c788ac::200>>}
          ],
          value: 1000
          }
        ]
      }
  """
  @spec add_output(Spec.t(), binary() | list(), integer()) :: Spec.t()
  def add_output(%Spec{} = spec, script_pub_key, value)
      when is_binary(script_pub_key) do
    parsed_script = script_pub_key |> Binary.from_hex() |> Script.parse!()
    Spec.add_output(spec, parsed_script, value)
  end

  def add_output(%Spec{outputs: outputs} = spec, script_pub_key, value)
      when is_list(script_pub_key) do
    output_spec = %Spec.Output{script_pub_key: script_pub_key, value: value}

    %{spec | outputs: [output_spec | outputs]}
  end

  @doc """
  Create a transaction from a spec

  ## Examples
      iex>  %BitcoinLib.Transaction.Spec{
      ...>    inputs: [
      ...>      %BitcoinLib.Transaction.Spec.Input{
      ...>        txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
      ...>        vout: 1,
      ...>        redeem_script: "76a914c39658833d83f2299416e697af2fb95a998853d388ac"
      ...>      }
      ...>    ],
      ...>    outputs: [%BitcoinLib.Transaction.Spec.Output{
      ...>      script_pub_key: [
      ...>        %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>        %BitcoinLib.Script.Opcodes.Data{value: <<0xad6a62e2d23d1c060897cd0cc79c42dad715e4c7::160>>},
      ...>        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...>      ],
      ...>      value: 1000
      ...>      }
      ...>    ]
      ...>  }
      ...>  |> BitcoinLib.Transaction.Spec.to_transaction()
      %BitcoinLib.Transaction{
        version: 2,
        id: "346330ef042212b04fabfdf91ce17f0c615a7458f159d4892d5e8385dbb742ce",
        inputs: [
          %BitcoinLib.Transaction.Input{
            txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
            vout: 1,
            script_sig: "76a914c39658833d83f2299416e697af2fb95a998853d388ac",
            sequence: 4294967293
          }
        ],
        outputs: [
          %BitcoinLib.Transaction.Output{
            value: 1000,
            script_pub_key: [
              %BitcoinLib.Script.Opcodes.Stack.Dup{},
              %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
              %BitcoinLib.Script.Opcodes.Data{value: <<0xad6a62e2d23d1c060897cd0cc79c42dad715e4c7::160>>},
              %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
              %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
            ]
          }
        ],
        locktime: 2404140,
        witness: []
      }
  """
  @spec to_transaction(Spec.t()) :: Transaction.t()
  def to_transaction(%Spec{
        version: version,
        outputs: spec_outputs,
        inputs: spec_inputs,
        locktime: locktime
      }) do
    transaction = %Transaction{
      version: version,
      locktime: locktime,
      outputs: Enum.map(spec_outputs, &Spec.Output.to_transaction_output/1),
      inputs: Enum.map(spec_inputs, &Spec.Input.to_transaction_input/1)
    }

    transaction
    |> Transaction.add_id()
  end

  @doc """
  With the help of a privat key, transforms a transaction into a signed binary that can be sent
  on the network so funds can be spent

  ## Examples
      iex>  private_key = BitcoinLib.Key.PrivateKey.from_seed_phrase(
      ...>    "rally celery split order almost twenty ignore record legend learn chaos decade"
      ...>  )
      ...>%BitcoinLib.Transaction.Spec{
      ...>  inputs: [
      ...>    %BitcoinLib.Transaction.Spec.Input{
      ...>      txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
      ...>      vout: 1,
      ...>      redeem_script: "76a914c39658833d83f2299416e697af2fb95a998853d388ac"
      ...>    }
      ...>  ],
      ...>  outputs: [%BitcoinLib.Transaction.Spec.Output{
      ...>    script_pub_key: [
      ...>      %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>      %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>      %BitcoinLib.Script.Opcodes.Data{value: <<0xad6a62e2d23d1c060897cd0cc79c42dad715e4c7::160>>},
      ...>      %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>      %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...>    ],
      ...>    value: 1000
      ...>    }
      ...>  ]
      ...>}
      ...>  |> BitcoinLib.Transaction.Spec.sign_and_encode([private_key])
      {
        :ok,
        "020000000126da6f8a25932979c0b1191c256e01ec3525ec9f87de78aeaf8acfef2b062569010000006b483045022100fdb5f58ab2dd24aeea72c0f832abde538e176f4474b3fe62a9c6e7e8a1a79e92022049565926bb564b996a19c6c3abd1dfbf35f9432ea7aadb10976dacee97d2e10c012102702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3fdffffff01e8030000000000001976a914ad6a62e2d23d1c060897cd0cc79c42dad715e4c788ac2caf2400"
      }
  """
  @spec sign_and_encode(Spec.t(), list(PrivateKey.t())) :: binary()
  def sign_and_encode(spec, private_keys) do
    spec
    |> to_transaction
    |> Transaction.sign_and_encode(private_keys)
  end
end
