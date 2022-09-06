defmodule BitcoinLib.Transaction.Spec do
  @moduledoc """
  A simplified version of a %BitcoinLib.Transaction that can be filled with human readable formats
  """

  defstruct inputs: [], outputs: []

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Script
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Spec

  @doc """
  Adds a human readable input into a transaction spec

  ## Examples
    iex> transaction_spec = %BitcoinLib.Transaction.Spec{}
    ...> transaction_spec
    ...> |> BitcoinLib.Transaction.Spec.add_input(
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
  @spec add_input(%Spec{}, list()) :: %Spec{}
  def add_input(
        %Spec{} = spec,
        txid: txid,
        vout: vout,
        redeem_script: redeem_script
      )
      when is_binary(redeem_script) do
    Spec.add_input(spec,
      txid: txid,
      vout: vout,
      redeem_script: redeem_script |> Binary.from_hex() |> Script.parse()
    )
  end

  def add_input(%Spec{inputs: inputs} = spec,
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
    iex> transaction_spec = %BitcoinLib.Transaction.Spec{}
    ...> transaction_spec
    ...> |> BitcoinLib.Transaction.Spec.add_output(
    ...>   script_pub_key: BitcoinLib.Script.Types.P2pkh.create(<<0xfc8ca28ea75e45f538242c257e1f07fe19baa0f3::160>>),
    ...>   value: 1000
    ...> )
    %BitcoinLib.Transaction.Spec{
      inputs: [],
      outputs: [%BitcoinLib.Transaction.Spec.Output{
        script_pub_key: [
          %BitcoinLib.Script.Opcodes.Stack.Dup{},
          %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
          %BitcoinLib.Script.Opcodes.Data{value: <<0xfc8ca28ea75e45f538242c257e1f07fe19baa0f3::160>>},
          %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
          %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
        ],
        value: 1000
        }
      ]
    }
  """
  @spec add_output(%Spec{}, list()) :: %Spec{}
  def add_output(%Spec{} = spec, script_pub_key: script_pub_key, value: value)
      when is_binary(script_pub_key) do
    Spec.add_output(spec,
      script_pub_key: script_pub_key |> Binary.from_hex() |> Script.parse(),
      value: value
    )
  end

  def add_output(%Spec{outputs: outputs} = spec, script_pub_key: script_pub_key, value: value)
      when is_list(script_pub_key) do
    output_spec = %Spec.Output{script_pub_key: script_pub_key, value: value}

    %{spec | outputs: [output_spec | outputs]}
  end

  def sign_and_encode(
        %Spec{outputs: spec_outputs, inputs: spec_inputs},
        %PrivateKey{} = private_key
      ) do
    %Transaction{
      version: 1,
      locktime: 0,
      outputs: Enum.map(spec_outputs, &Spec.Output.to_transaction_output/1),
      inputs: Enum.map(spec_inputs, &Spec.Input.to_transaction_input/1)
    }
    |> Transaction.sign_and_encode(private_key)
  end
end
